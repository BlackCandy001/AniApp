import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/local/database_helper.dart';
import '../../data/api/jikan_api_service.dart';
import '../../data/models/watchlist_model.dart';
import 'notification_service.dart';

/// Dịch vụ tự động kiểm tra cập nhật anime trong Watchlist.
///
/// So sánh số tập hiện tại trên Jikan API với số tập đã lưu trong DB.
/// Gửi [NotificationService] khi phát hiện tập mới hoặc phim bắt đầu chiếu.
/// Áp dụng delay 600ms giữa mỗi lần gọi API để tránh vượt Rate Limit.
class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  final JikanApiService _apiService = JikanApiService();
  bool _isChecking = false;

  /// Kiểm tra cập nhật cho tất cả anime đang Xem và Theo dõi.
  /// Trả về số lượng anime có cập nhật mới.
  Future<int> checkForUpdates() async {
    if (_isChecking) return 0;
    _isChecking = true;
    int updatesCount = 0;

    try {
      final db = await DatabaseHelper.instance.database;

      // Lấy user_id hiện tại từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('logged_in_user_id') ?? 0;

      // Chỉ kiểm tra phim đang xem hoặc đang theo dõi của người dùng hiện tại
      final maps = await db.query(
        'watchlist',
        where: 'status IN (?, ?) AND user_id = ?',
        whereArgs: ['watching', 'following', userId],
      );

      if (maps.isEmpty) return 0;

      final watchlist = maps.map((map) => WatchlistModel.fromMap(map)).toList();

      for (var item in watchlist) {
        try {
          // Gọi API để lấy thông tin mới nhất
          final latestAnime = await _apiService.getAnimeDetails(item.malId);
          
          // Dùng API đúng để đếm số tập đã phát thực tế
          final airedCount = await _apiService.getAiredEpisodesCount(item.malId);

          bool hasUpdate = false;
          String notifyBody = '';

          // Đọc ngôn ngữ hiện tại từ SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final lang = prefs.getString('app_language') ?? 'en';

          // Kiểm tra tập mới
          final savedEpisodes = item.episodesTotal ?? 0;
          if (airedCount > savedEpisodes && airedCount > 0) {
            hasUpdate = true;
            
            if (savedEpisodes == 0 && airedCount == 1) {
              notifyBody = AppLocalizations.get(lang, 'notify_episode_started');
            } else {
              notifyBody = AppLocalizations.get(lang, 'notify_episode_new')
                  .replaceFirst('{aired}', '$airedCount')
                  .replaceFirst('{saved}', '$savedEpisodes');
            }
          }

          if (hasUpdate) {
            updatesCount++;

            // Gửi thông báo cho người dùng
            await NotificationService().showNotification(
              id: item.malId,
              title: '🎌 ${item.title}',
              body: notifyBody,
            );

            // Cập nhật số tập đã phát trong DB để không thông báo lại
            await db.update(
              'watchlist',
              {
                'episodes_total': airedCount,
                'updated_at': DateTime.now().toIso8601String(),
              },
              where: 'mal_id = ? AND user_id = ?',
              whereArgs: [item.malId, userId],
            );
          }

          // Dừng một chút để tránh vượt Rate Limit của Jikan API
          await Future.delayed(const Duration(milliseconds: 600));
        } catch (e) {
          debugPrint('Lỗi kiểm tra anime ID ${item.malId}: $e');
        }
      }
    } catch (e) {
      debugPrint('Lỗi TrackingService.checkForUpdates: $e');
    } finally {
      _isChecking = false;
    }

    return updatesCount;
  }

  bool get isChecking => _isChecking;
}
