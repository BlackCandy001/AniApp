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
      version: 3,
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
  mal_id $integerType UNIQUE,
  title $textType,
  title_japanese $textNullableType,
  poster_url $textType,
  status $textType,
  episodes_total $integerNullableType,
  episodes_watched $integerType DEFAULT 0,
  score_user $realNullableType,
  genres $textNullableType,
  added_at $textType,
  updated_at $textType
)
''');

    await db.execute('''
CREATE TABLE notes (
  id $idType,
  mal_id $integerType,
  content $textType,
  created_at $textType,
  FOREIGN KEY (mal_id) REFERENCES watchlist (mal_id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE watch_history (
  id $idType,
  mal_id $integerType,
  action $textType,
  action_at $textType,
  FOREIGN KEY (mal_id) REFERENCES watchlist (mal_id) ON DELETE CASCADE
)
''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
