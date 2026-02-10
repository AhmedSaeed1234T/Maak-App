import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/screens/login_screen.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:flutter/material.dart';

/// Checks session validity with proper offline handling
/// - Validates local tokens (instant, no API call)
/// - Enforces 2-day offline limit
/// - Shows appropriate Arabic messages
///
/// Returns true if session is valid, false if user needs to login
Future<bool> checkSessionValidity(
  BuildContext context,
  TokenService tokenService,
) async {
  debugPrint("🔍 Checking session validity...");

  // ✅ Call TokenService method (handles all logic)
  final result = await tokenService.checkSessionValidity();

  debugPrint("📊 Session check result: ${result.reason}");

  // Handle invalid session
  if (!result.isValid) {
    if (result.showOfflineWarning) {
      // ⭐ 2+ DAYS OFFLINE - Must connect to internet ⭐
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text(
              'يجب الاتصال بالإنترنت',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'يجب عليك الاتصال بالإنترنت لمواصلة استخدام التطبيق. '
              'هذا مطلوب للتحقق الأمني.',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'حسناً',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      // Normal logout (token/subscription expired)
      if (context.mounted) {
        // ✅ Only show subscription message if IT IS ACTUALLY EXPIRED.
        // For "eligible" users (valid sub but tokens died), we stay silent or show generic msg.
        if (result.isSubscriptionExpired) {
          CustomSnackBar.show(
            context,
            message: 'لقد انتهي اشتراكك',
            type: SnackBarType.error,
            duration: 4,
          );
        } else {
          debugPrint(
            "🚪 Logging out eligible user (session died/tokens expired)",
          );
          // Optional: Generic session expired message could go here if user wants.
          // For now, per request, we avoid blaming the subscription.
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return false;
  }

  // ✅ Session is valid - no need to show anything
  debugPrint("✅ Session valid");
  return true;
}
