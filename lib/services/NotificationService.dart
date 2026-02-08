// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final FlutterLocalNotificationsPlugin notificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// class NotificationService {
//   /// Initialize notifications
//   static Future<void> initialize() async {
//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     const iosSettings = DarwinInitializationSettings(); // iOS
//     const settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await notificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (details) {
//         // Handle tap on notification (optional)
//       },
//     );
//   }

//   /// Show notification
//   static Future<void> showNotification({
//     required String title,
//     required String body,
//     int id = 0,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'subscription_channel',
//       'Subscription Notifications',
//       channelDescription: 'Notifies user about subscription expiry',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const iosDetails = DarwinNotificationDetails();

//     const platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await notificationsPlugin.show(id, title, body, platformDetails);
//   }
// }
