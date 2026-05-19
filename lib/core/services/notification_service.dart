import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Singleton dịch vụ thông báo push nội bộ (áp dụng cho Android/iOS).
/// Trên Windows, thông báo sẽ được in ra debug console thay vì hiển thị thật.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Chỉ khởi tạo trên các nền tảng được hỗ trợ
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    // Xin quyền trên Android 13+
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Không làm gì nếu không phải nền tảng di động/macOS, chuyển sang giả lập log
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      if (kDebugMode) {
        debugPrint('\n==================================');
        debugPrint('🔔 [THÔNG BÁO] $title');
        debugPrint('📝 $body');
        debugPrint('==================================\n');
      }
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ani_tracker_channel',
      'AniTracker Notifications',
      channelDescription: 'Thông báo cập nhật anime mới',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }
}
