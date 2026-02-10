import 'package:flutter/material.dart';

class SubscriptionHandler {
  static void handleSubscriptionStatus({
    required BuildContext context,
    required bool isExpired,
    String? expiryDate,
  }) {
    if (isExpired) {
      String message = "انتهى اشتراكك. يرجى تجديد الاشتراك للمتابعة.";
      // Removed date-based message per user request

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "تنبيه الاشتراك",
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("حسنًا", style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      );
    }
  }
}
