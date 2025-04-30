import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize timezone database
    tz_data.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
    // You can add navigation logic here based on the payload
  }

  Future<void> requestPermissions() async {
    if (!_isInitialized) await initialize();

    // Android doesn't need explicit permission request for newer versions
    // iOS needs explicit permission request
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleDailyBudgetReminder({
    required TimeOfDay time,
    required String message,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    await _notificationsPlugin.zonedSchedule(
      0,
      'Budget Reminder',
      message,
      _nextInstanceOfTime(time),
      NotificationDetails(
        android: _androidNotificationDetails('daily_budget_channel'),
        iOS: _darwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    await _notificationsPlugin.show(
      _generateNotificationId(),
      title,
      body,
      NotificationDetails(
        android: _androidNotificationDetails('instant_notifications_channel'),
        iOS: _darwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> showProgressNotification({
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    await _notificationsPlugin.show(
      _generateNotificationId(),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'progress_notifications_channel',
          'Progress Notifications',
          channelDescription: 'Notifications showing progress updates',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          onlyAlertOnce: true,
        ),
        iOS: _darwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await initialize();
    await _notificationsPlugin.cancel(id);
  }

  // Helper methods
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  AndroidNotificationDetails _androidNotificationDetails(String channelId) {
    return AndroidNotificationDetails(
      channelId,
      channelId.replaceAll('_', ' ').titleCase(),
      channelDescription: 'Channel for $channelId notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      enableVibration: true,
      playSound: true,
    );
  }

  DarwinNotificationDetails _darwinNotificationDetails() {
    return const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
  }

  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }
}

// Extension to title case strings
extension StringExtensions on String {
  String titleCase() {
    return split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}