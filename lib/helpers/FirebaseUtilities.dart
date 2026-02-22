import 'dart:async';
import 'dart:convert';

import 'package:abokamall/helpers/ServiceLocator.dart';
import 'dart:async';
import 'dart:convert';

import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/apiclient.dart';
import 'package:abokamall/main.dart';
import 'package:abokamall/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ===============================
/// 🔥 Firebase Notification System
/// ===============================
class FirebaseUtilities {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'default_channel';
  static const String _channelName = 'Default Notifications';
  static const String _channelDesc = 'Main notification channel';

  /// ===============================
  /// INIT (call in main.dart)
  /// ===============================
  static Future<void> init() async {
    await _initPermissions();
    await _initLocalNotifications();
    await _initFirebaseListeners();
  }

  /// ===============================
  /// Permissions (Android 13+ fix)
  /// ===============================
  static Future<void> _initPermissions() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// ===============================
  /// Local Notifications Init
  /// ===============================
  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            _handleDataNavigation(data);
          } catch (e) {
            debugPrint('Error parsing payload: $e');
          }
        }
      },
    );

    // 🔥 CREATE ANDROID CHANNEL (MANDATORY)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);
  }

  /// ===============================
  /// Firebase Listeners
  /// ===============================
  static Future<void> _initFirebaseListeners() async {
    // Foreground
    FirebaseMessaging.onMessage.listen((message) {
      showLocalNotification(message);
    });

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleNotificationClick(message);
    });
  }

  /// ===============================
  /// Background handler
  /// ===============================
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
  }

  /// ===============================
  /// Token Sync
  /// ===============================
  static Future<void> syncFcmTokenWithBackend() async {
    try {
      final String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      debugPrint("🔥 FCM TOKEN: $token");

      final ApiClient apiClient = getIt<ApiClient>();

      await apiClient.post('/auth/add-firebase-token', body: {"fcm": token});
    } catch (e) {
      debugPrint('❌ FCM token sync failed: $e');
    }
  }

  /// ===============================
  /// Delete local token
  /// ===============================
  static Future<void> deleteLocalFcmToken() async {
    await FirebaseMessaging.instance.deleteToken();
  }

  /// ===============================
  /// Show Notification
  /// ===============================
  static Future<void> showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          color: Colors.blue,
          subText: "معاك",
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    final title =
        message.notification?.title ?? message.data['title'] ?? 'Notification';

    final body = message.notification?.body ?? message.data['body'] ?? '';

    await _localNotificationsPlugin.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      notificationDetails: platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// ===============================
  /// Click handler
  /// ===============================
  static Map<String, dynamic>? pendingNotificationData;

  static void handleNotificationClick(RemoteMessage message) {
    _handleDataNavigation(message.data);
  }

  static void _handleDataNavigation(Map<String, dynamic> data) {
    debugPrint("📩 Notification clicked: $data");

    final senderId = data['senderId'];
    final senderName = data['senderName'] ?? 'User';
    final senderImage = data['senderImage'];
    debugPrint("I should go for it now");

    if (senderId != null) {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              targetUserId: senderId,
              targetUserName: senderName,
              targetUserImage: senderImage,
            ),
          ),
        );
      } else {
        debugPrint("⚠️ Navigator not ready, saving pending notification");
        pendingNotificationData = data;
      }
    }
  }

  /// ===============================
  /// Process Pending Notifications
  /// ===============================
  /// Call this method once the navigator is ready (e.g., after splash screen)
  static void processPendingNotification() {
    if (pendingNotificationData != null) {
      debugPrint("🔔 Processing pending notification");
      _handleDataNavigation(pendingNotificationData!);
      pendingNotificationData = null;
    }
  }
}

/// ===============================
/// 🔥 Main App Listener Service
/// ===============================
class NotificationService {
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openAppSub;

  void init() {
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      FirebaseUtilities.showLocalNotification(message);
    });

    _openAppSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      FirebaseUtilities.handleNotificationClick(message);
    });
  }

  void dispose() {
    _foregroundSub?.cancel();
    _openAppSub?.cancel();
  }
}
