import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';


/// Singleton quản lý SQLite database cho toàn bộ ứng dụng.
///
/// Schema gồm 4 bảng:
/// - [users]: Tài khoản người dùng (đăng nhập local)
/// - [watchlist]: Danh sách anime đã thêm và tiến độ xem
/// - [notes]: Ghi chú cá nhân cho từng anime
/// - [watch_history]: Lịch sử các hành động (thêm/cập nhật)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('animetracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("UPDATE watchlist SET status = 'following' WHERE status = 'plan'");
      await db.execute("DELETE FROM watchlist WHERE status = 'dropped'");
    }
    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        username TEXT NOT NULL,
        avatar_path TEXT,
        created_at TEXT NOT NULL
      )
      ''');
    }
    if (oldVersion < 4) {
      // Tạo lại bảng watchlist với user_id và UNIQUE(mal_id, user_id)
      await db.execute('''
        CREATE TABLE watchlist_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL DEFAULT 0,
          mal_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          title_japanese TEXT,
          poster_url TEXT NOT NULL,
          status TEXT NOT NULL,
          episodes_total INTEGER,
          episodes_watched INTEGER NOT NULL DEFAULT 0,
          score_user REAL,
          genres TEXT,
          added_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          UNIQUE(mal_id, user_id)
        )
      ''');
      // Copy dữ liệu cũ sang bảng mới, gán user_id = 0
      await db.execute('''
        INSERT INTO watchlist_new
          (user_id, mal_id, title, title_japanese, poster_url, status,
           episodes_total, episodes_watched, score_user, genres, added_at, updated_at)
        SELECT 0, mal_id, title, title_japanese, poster_url, status,
           episodes_total, episodes_watched, score_user, genres, added_at, updated_at
        FROM watchlist
      ''');
      await db.execute('DROP TABLE watchlist');
      await db.execute('ALTER TABLE watchlist_new RENAME TO watchlist');
    }
    if (oldVersion < 5) {
      // Recreate notes without foreign key constraint
      await db.execute('CREATE TABLE IF NOT EXISTS notes_new (id INTEGER PRIMARY KEY AUTOINCREMENT, mal_id INTEGER NOT NULL, content TEXT NOT NULL, created_at TEXT NOT NULL)');
      // Copy existing notes if table exists
      try {
        await db.execute('INSERT INTO notes_new (id, mal_id, content, created_at) SELECT id, mal_id, content, created_at FROM notes');
      } catch (_) {}
      await db.execute('DROP TABLE IF EXISTS notes');
      await db.execute('ALTER TABLE notes_new RENAME TO notes');

      // Recreate watch_history without foreign key constraint
      await db.execute('CREATE TABLE IF NOT EXISTS watch_history_new (id INTEGER PRIMARY KEY AUTOINCREMENT, mal_id INTEGER NOT NULL, action TEXT NOT NULL, action_at TEXT NOT NULL)');
      // Copy existing watch_history if table exists
      try {
        await db.execute('INSERT INTO watch_history_new (id, mal_id, action, action_at) SELECT id, mal_id, action, action_at FROM watch_history');
      } catch (_) {}
      await db.execute('DROP TABLE IF EXISTS watch_history');
      await db.execute('ALTER TABLE watch_history_new RENAME TO watch_history');
    }
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerNullableType = 'INTEGER';
    const realNullableType = 'REAL';

    await db.execute('''
CREATE TABLE users (
  id $idType,
  email $textType UNIQUE,
  password $textType,
  username $textType,
  avatar_path $textNullableType,
  created_at $textType
)
''');

    await db.execute('''
CREATE TABLE watchlist (
  id $idType,
  user_id $integerType DEFAULT 0,
  mal_id $integerType,
  title $textType,
  title_japanese $textNullableType,
  poster_url $textType,
  status $textType,
  episodes_total $integerNullableType,
  episodes_watched $integerType DEFAULT 0,
  score_user $realNullableType,
  genres $textNullableType,
  added_at $textType,
  updated_at $textType,
  UNIQUE(mal_id, user_id)
)
''');

    await db.execute('''
CREATE TABLE notes (
  id $idType,
  mal_id $integerType,
  content $textType,
  created_at $textType
)
''');

    await db.execute('''
CREATE TABLE watch_history (
  id $idType,
  mal_id $integerType,
  action $textType,
  action_at $textType
)
''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
