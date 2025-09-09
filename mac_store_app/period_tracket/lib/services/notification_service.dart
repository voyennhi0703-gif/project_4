import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Khởi tạo timezone
    tz.initializeTimeZones();

    // Cấu hình cho Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Cấu hình cho iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Yêu cầu quyền thông báo
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Yêu cầu quyền thông báo cho Android 13+
    await Permission.notification.request();

    // Yêu cầu quyền chính xác cho Android (để lên lịch thông báo)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Xử lý khi người dùng tap vào thông báo
    print('Notification tapped: ${response.payload}');
  }

  // Lên lịch thông báo nhắc kỳ kinh
  Future<void> schedulePeriodReminder(TimeOfDay time, int daysBefore) async {
    // Tính ngày dự đoán kỳ kinh tiếp theo (ví dụ)
    final now = DateTime.now();
    final nextPeriodDate = now.add(
      const Duration(days: 28),
    ); // Giả sử chu kỳ 28 ngày
    final notificationDate = nextPeriodDate.subtract(
      Duration(days: daysBefore),
    );

    // Đặt giờ thông báo
    final scheduledDate = DateTime(
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      time.hour,
      time.minute,
    );

    await _scheduleNotification(
      id: 1,
      title: 'Period Tracket',
      body:
          'Một chu kỳ mới sẽ bắt đầu trong vài ngày nửa. Đừng quên ghi tất cả các triệu chứn vào lịch!',
      scheduledDate: scheduledDate,
      payload: 'period_reminder',
    );
  }

  // Lên lịch thông báo nhắc rụng trứng
  Future<void> scheduleOvulationReminder(TimeOfDay time) async {
    final now = DateTime.now();
    final nextOvulationDate = now.add(
      const Duration(days: 14),
    ); // Giả sử rụng trứng sau 14 ngày

    final scheduledDate = DateTime(
      nextOvulationDate.year,
      nextOvulationDate.month,
      nextOvulationDate.day,
      time.hour,
      time.minute,
    );

    await _scheduleNotification(
      id: 2,
      title: 'Flo',
      body: 'Hôm nay là ngày rụng trứng dự đoán!',
      scheduledDate: scheduledDate,
      payload: 'ovulation_reminder',
    );
  }

  // Lên lịch thông báo nhắc uống thuốc
  Future<void> schedulePillReminder(TimeOfDay time) async {
    await _scheduleDailyNotification(
      id: 3,
      title: 'Flo',
      body: 'Đừng quên uống thuốc tránh thai!',
      time: time,
      payload: 'pill_reminder',
    );
  }

  // Lên lịch thông báo thông minh
  Future<void> scheduleSmartReminder(TimeOfDay time) async {
    await _scheduleDailyNotification(
      id: 4,
      title: 'Flo',
      body: 'Hãy ghi lại cảm giác hôm nay của bạn!',
      time: time,
      payload: 'smart_reminder',
    );
  }

  // Hàm chung để lên lịch thông báo một lần
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'period_tracker_channel',
          'Period Tracker',
          channelDescription: 'Thông báo cho ứng dụng theo dõi chu kỳ',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFFF6B9D), // Màu hồng của app
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.active,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Hàm lên lịch thông báo hàng ngày
  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String payload,
  }) async {
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Nếu giờ đã qua hôm nay, lên lịch cho ngày mai
    final finalDate = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: finalDate,
      payload: payload,
    );
  }

  // Hủy thông báo theo ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Kiểm tra quyền thông báo
  Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}
