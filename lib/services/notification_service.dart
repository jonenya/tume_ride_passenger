import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class NotificationService {
  // static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static Function(Map<String, dynamic>)? _onNotificationTap;

  static Future<void> initialize() async {
    // COMMENTED OUT FOR WEB TESTING
    // Initialize local notifications
    // const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    // const InitializationSettings settings = InitializationSettings(
    //   android: androidSettings,
    //   iOS: iosSettings,
    // );
    // await _localNotifications.initialize(settings);
    //
    // // Request permissions
    // await _firebaseMessaging.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    //
    // // Get token
    // final token = await _firebaseMessaging.getToken();
    // print('FCM Token: $token');
    //
    // // Handle foreground messages
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    //
    // // Handle background messages
    // FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    //
    // // Handle when app is opened from terminated state
    // RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    // if (initialMessage != null) {
    //   _handleMessage(initialMessage.data);
    // }
    //
    // // Handle when app is opened from background
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   _handleMessage(message.data);
    // });

    print('Notification service initialized (web mode - disabled)');
  }

  // static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  //   print('Background message: ${message.data}');
  // }

  // static void _handleForegroundMessage(RemoteMessage message) {
  //   print('Foreground message: ${message.data}');
  //   _showLocalNotification(
  //     title: message.notification?.title ?? 'Tume Ride',
  //     body: message.notification?.body ?? '',
  //     data: message.data,
  //   );
  // }

  // static Future<void> _showLocalNotification({
  //   required String title,
  //   required String body,
  //   Map<String, dynamic>? data,
  // }) async {
  //   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //     'tume_ride_channel',
  //     'Tume Ride Notifications',
  //     channelDescription: 'Notifications for rides, payments, and promos',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //     color: AppColors.primary,
  //     icon: '@mipmap/ic_launcher',
  //   );
  //
  //   const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );
  //
  //   const NotificationDetails details = NotificationDetails(
  //     android: androidDetails,
  //     iOS: iosDetails,
  //   );
  //
  //   await _localNotifications.show(
  //     DateTime.now().millisecond,
  //     title,
  //     body,
  //     details,
  //     payload: data != null ? data.toString() : null,
  //   );
  // }

  // static void _handleMessage(Map<String, dynamic> data) {
  //   if (_onNotificationTap != null) {
  //     _onNotificationTap!(data);
  //   }
  // }

  static void setOnNotificationTap(Function(Map<String, dynamic>) callback) {
    _onNotificationTap = callback;
  }

  static Future<void> updateDeviceToken(String userId) async {
    // final token = await _firebaseMessaging.getToken();
    // TODO: Send token to backend
    print('Device token for user $userId: web-disabled');
  }
}