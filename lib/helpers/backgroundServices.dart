// import 'package:abokamall/services/NotificationService.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// const checkSubscriptionTask = "checkSubscriptionTask";

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     final prefs = await SharedPreferences.getInstance();
//     final expirationDateString = prefs.getString("subscription_expiry");
//     if (expirationDateString == null) return Future.value(true);

//     final expirationDate = DateTime.parse(expirationDateString);
//     final daysLeft = expirationDate
//         .difference(DateTime(today.year, today.month, today.day))
//         .inDays;

//     await NotificationService.initialize();

//     String? message;
//     if (daysLeft == 3) {
//       message = "متبقي 3 أيام على انتهاء الاشتراك";
//     } else if (daysLeft == 2) {
//       message = "متبقي يومان على انتهاء الاشتراك";
//     } else if (daysLeft == 1) {
//       message = "غداً هو آخر يوم للاشتراك";
//     } else if (daysLeft == 0) {
//       message = "اليوم ينتهي اشتراكك، برجاء التجديد لتجنب الإيقاف";
//     }

//     if (message != null) {
//       await NotificationService.showNotification(
//         title: "إشعار الاشتراك",
//         body: message,
//       );
//     }

//     return Future.value(true);
//   });
// }
