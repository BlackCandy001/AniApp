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
    // Chỉ khởi tạo trên các nền tảng được hỗ trợ (không cần thiết trên Windows desktop)
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
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Không làm gì nếu không phải nền tảng di động/macOS
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      debugPrint('🔔 [Thông báo giả lập] $title: $body');
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
