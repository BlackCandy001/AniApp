import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:aniapp/data/local/database_helper.dart';
import 'package:aniapp/data/models/watchlist_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Inspect Watchlist Table Schema and Try Insertion', () async {
    print('--- DB TEST INITIATED ---');
    try {
      final db = await DatabaseHelper.instance.database;
      
      // 1. Query sqlite_master for table definition
      final masterQuery = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='watchlist'"
      );
      if (masterQuery.isNotEmpty) {
        print('Watchlist Schema:\n${masterQuery.first['sql']}');
      } else {
        print('Watchlist table does not exist!');
      }

      // 2. Query columns info using PRAGMA table_info
      final tableInfo = await db.rawQuery("PRAGMA table_info(watchlist)");
      print('\nWatchlist Column Details:');
      for (final col in tableInfo) {
        print('Column: ${col['name']} | Type: ${col['type']} | NotNull: ${col['notnull']} | Default: ${col['dflt_value']}');
      }

      // 3. Try querying existing records
      final countResult = await db.rawQuery("SELECT COUNT(*) as cnt FROM watchlist");
      print('\nCurrent Watchlist Record Count: ${countResult.first['cnt']}');

      // 4. Try inserting a mock item
      print('\nTrying to insert test watchlist item...');
      final watchItem = WatchlistModel(
        userId: 0,
        malId: 999999, // dummy ID
        title: 'Test Dummy Anime',
        posterUrl: 'https://example.com/test.jpg',
        status: 'watching',
        episodesTotal: 12,
        episodesWatched: 1,
        scoreUser: 8.5,
        addedAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final insertId = await db.insert(
        'watchlist',
        watchItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Insert successful! ID: $insertId');

      // Clean up the dummy item
      await db.delete('watchlist', where: 'mal_id = ?', whereArgs: [999999]);
      print('Cleanup successful.');

    } catch (e, st) {
      print('CRITICAL DB ERROR OCCURRED:');
      print(e);
      print(st);
      fail('DB test failed with exception: $e');
    }
  });
}
