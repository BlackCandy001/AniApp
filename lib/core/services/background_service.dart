import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local/database_helper.dart';
import '../../data/api/jikan_api_service.dart';
import '../../data/models/watchlist_model.dart';
import 'notification_service.dart';
import '../localization/app_localizations.dart';

/// Tên và tag định danh cho periodic task
const String kEpisodeCheckTaskName = 'episodeCheckTask';
const String kEpisodeCheckTaskTag = 'ani_episode_check';

/// Hàm callback thực thi trong background isolate — phải là top-level function.
/// Workmanager sẽ gọi hàm này mỗi khi task được kích hoạt.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == kEpisodeCheckTaskName) {
        await _runEpisodeCheck();
      }
    } catch (e) {
      debugPrint('[BackgroundService] Lỗi task $taskName: $e');
      return Future.value(false); // Báo task thất bại để WorkManager retry
    }
    return Future.value(true); // Task thành công
  });
}

/// Logic kiểm tra tập mới — chạy trong background isolate.
/// Không thể dùng Riverpod ở đây, phải truy cập trực tiếp qua singletons.
Future<void> _runEpisodeCheck() async {
  // Không chạy trên Windows/Linux (chỉ dành cho Android)
  if (!Platform.isAndroid && !Platform.isIOS) return;

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('logged_in_user_id') ?? 0;
  final lang = prefs.getString('app_language') ?? 'en';

  final db = await DatabaseHelper.instance.database;
  final apiService = JikanApiService();
  await NotificationService().init();

  final maps = await db.query(
    'watchlist',
    where: 'status IN (?, ?) AND user_id = ?',
    whereArgs: ['watching', 'following', userId],
  );

  if (maps.isEmpty) return;

  final watchlist = maps.map((m) => WatchlistModel.fromMap(m)).toList();

  for (final item in watchlist) {
    try {
      final airedCount = await apiService.getAiredEpisodesCount(item.malId);
      final savedEpisodes = item.episodesTotal ?? 0;

      if (airedCount > savedEpisodes && airedCount > 0) {
        final String body;
        if (savedEpisodes == 0 && airedCount == 1) {
          body = AppLocalizations.get(lang, 'notify_episode_started');
        } else {
          body = AppLocalizations.get(lang, 'notify_episode_new')
              .replaceFirst('{aired}', '$airedCount')
              .replaceFirst('{saved}', '$savedEpisodes');
        }

        await NotificationService().showNotification(
          id: item.malId,
          title: '🎌 ${item.title}',
          body: body,
        );

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

      // Rate limit 800ms để tránh bị Jikan API chặn trong background
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      debugPrint('[BackgroundService] Lỗi anime ID ${item.malId}: $e');
    }
  }
}

/// Quản lý đăng ký và hủy background task.
class BackgroundService {
  static const _frequencyHours = 12; // Kiểm tra mỗi 12 giờ

  /// Khởi tạo WorkManager và đăng ký periodic task.
  /// Gọi trong main() sau khi NotificationService đã init.
  static Future<void> init() async {
    // WorkManager chỉ hỗ trợ Android và iOS
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );

      // Đăng ký periodic task — tự động chạy định kỳ kể cả khi app đóng
      await Workmanager().registerPeriodicTask(
        kEpisodeCheckTaskTag,
        kEpisodeCheckTaskName,
        frequency: const Duration(hours: _frequencyHours),
        initialDelay: const Duration(minutes: 5), // Delay 5 phút sau lần đầu cài đặt
        constraints: Constraints(
          networkType: NetworkType.connected, // Chỉ chạy khi có mạng
          requiresBatteryNotLow: true,        // Không chạy khi pin yếu
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep, // Giữ task cũ nếu đã có
      );

      debugPrint('[BackgroundService] Đã đăng ký periodic task (mỗi ${_frequencyHours}h)');
    } catch (e, st) {
      debugPrint('[BackgroundService] Lỗi khởi tạo WorkManager: $e\n$st');
    }
  }

  /// Hủy đăng ký task (dùng khi cần tắt hoàn toàn tính năng).
  static Future<void> cancel() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    await Workmanager().cancelByTag(kEpisodeCheckTaskTag);
    debugPrint('[BackgroundService] Đã hủy periodic task');
  }
}
