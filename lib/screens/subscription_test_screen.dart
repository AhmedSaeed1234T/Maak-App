// import 'package:abokamall/helpers/backgroundServices.dart';
// import 'package:abokamall/services/NotificationService.dart';
// import 'package:flutter/material.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SubscriptionTestPage extends StatefulWidget {
//   const SubscriptionTestPage({super.key});

//   @override
//   State<SubscriptionTestPage> createState() => _SubscriptionTestPageState();
// }

// class _SubscriptionTestPageState extends State<SubscriptionTestPage> {
//   DateTime? expiryDate;

//   @override
//   void initState() {
//     super.initState();
//     _loadExpiryDate();
//   }

//   Future<void> _loadExpiryDate() async {
//     final prefs = await SharedPreferences.getInstance();
//     final dateString = prefs.getString("subscription_expiry");
//     if (dateString != null) {
//       setState(() {
//         expiryDate = DateTime.parse(dateString);
//       });
//     }
//   }

//   Future<void> _setExpiryDate(DateTime date) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("subscription_expiry", date.toIso8601String());
//     setState(() => expiryDate = date);
//   }

//   Future<void> _triggerNotification() async {
//     await Workmanager().registerOneOffTask(
//       "manualTrigger",
//       checkSubscriptionTask,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Subscription Notification Test")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               "Subscription expiry: ${expiryDate?.toIso8601String() ?? 'Not set'}",
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 // Set expiry date 3 days from now for testing
//                 _setExpiryDate(DateTime.now().add(Duration(days: 3)));
//               },
//               child: Text("Set expiry date 3 days from now"),
//             ),
//             ElevatedButton(
//               onPressed: _triggerNotification,
//               child: Text("Trigger Notification Now"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
