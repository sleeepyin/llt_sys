import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/clothing.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 初始化时区数据
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {},
      onDidReceiveBackgroundNotificationResponse: (NotificationResponse response) async {},
    );
  }

  // 显示即时通知
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  // 安排通知在特定时间发送（用于闹钟提醒）
  Future<void> scheduleNotification(Clothing item, DateTime scheduledTime) async {
    if (item.reminderEnabled != true || item.reminderType == null) return;

    final tz.TZDateTime scheduledDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_channel_id',
      '闹钟提醒',
      channelDescription: '用于尾款支付提醒的闹钟',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      item.id.hashCode,
      '尾款支付提醒',
      '${item.name}的尾款支付截止日期即将到来！\n截止日期：${item.formattedDeadline}',
      scheduledDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: item.id,
    );
  }

  // 取消特定商品的所有提醒
  Future<void> cancelNotification(Clothing item) async {
    await flutterLocalNotificationsPlugin.cancel(item.id.hashCode);
  }

  // 取消所有提醒
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}