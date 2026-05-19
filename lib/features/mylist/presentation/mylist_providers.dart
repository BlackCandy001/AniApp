import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../data/models/watchlist_model.dart';
import '../../../../data/local/database_helper.dart';

class WatchlistNotifier extends StateNotifier<AsyncValue<List<WatchlistModel>>> {
  final Ref ref;

  WatchlistNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadWatchlist();
  }

  /// Lấy user_id hiện tại từ SharedPreferences.
  /// Trả về 0 nếu chưa đăng nhập (chế độ khách).
  Future<int> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('logged_in_user_id') ?? 0;
  }

  Future<void> loadWatchlist() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final userId = await _getCurrentUserId();
      final maps = await db.query(
        'watchlist',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC',
      );
      final list = maps.map((map) => WatchlistModel.fromMap(map)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addOrUpdate(WatchlistModel item) async {
    final db = await DatabaseHelper.instance.database;
    final userId = await _getCurrentUserId();
    final itemWithUser = WatchlistModel(
      id: item.id,
      userId: userId,
      malId: item.malId,
      title: item.title,
      titleJapanese: item.titleJapanese,
      posterUrl: item.posterUrl,
      status: item.status,
      episodesTotal: item.episodesTotal,
      episodesWatched: item.episodesWatched,
      scoreUser: item.scoreUser,
      genres: item.genres,
      addedAt: item.addedAt,
      updatedAt: item.updatedAt,
    );
    await db.insert('watchlist', itemWithUser.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await loadWatchlist();
  }

  Future<void> delete(int malId) async {
    final db = await DatabaseHelper.instance.database;
    final userId = await _getCurrentUserId();
    await db.delete(
      'watchlist',
      where: 'mal_id = ? AND user_id = ?',
      whereArgs: [malId, userId],
    );
    // Xóa thủ công vì đã loại bỏ foreign key
    await db.delete('notes', where: 'mal_id = ?', whereArgs: [malId]);
    await db.delete('watch_history', where: 'mal_id = ?', whereArgs: [malId]);
    
    await loadWatchlist();
  }

  Future<String> exportData() async {
    final db = await DatabaseHelper.instance.database;
    final userId = await _getCurrentUserId();
    final maps = await db.query(
      'watchlist',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return jsonEncode(maps);
  }

  Future<void> deleteAll() async {
    final db = await DatabaseHelper.instance.database;
    final userId = await _getCurrentUserId();
    await db.delete(
      'watchlist',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    await loadWatchlist();
  }
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<List<WatchlistModel>>>(
    (ref) => WatchlistNotifier(ref));
