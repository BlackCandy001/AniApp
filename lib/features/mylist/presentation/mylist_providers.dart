import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../data/models/watchlist_model.dart';
import '../../../../data/local/database_helper.dart';

class WatchlistNotifier extends StateNotifier<AsyncValue<List<WatchlistModel>>> {
  WatchlistNotifier() : super(const AsyncValue.loading()) {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query('watchlist', orderBy: 'updated_at DESC');
      final list = maps.map((map) => WatchlistModel.fromMap(map)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addOrUpdate(WatchlistModel item) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('watchlist', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await loadWatchlist();
  }

  Future<void> delete(int malId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('watchlist', where: 'mal_id = ?', whereArgs: [malId]);
    await loadWatchlist();
  }

  Future<String> exportData() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('watchlist');
    return jsonEncode(maps);
  }

  Future<void> deleteAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('watchlist');
    await loadWatchlist();
  }
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<List<WatchlistModel>>>(
    (ref) => WatchlistNotifier());
