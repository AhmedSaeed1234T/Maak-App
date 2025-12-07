import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/screens/login_screen.dart';
import 'package:flutter/material.dart';

Future<void> goToLogin(BuildContext context) async {
  if (!context.mounted) return;

  // Prevent navigation if already on LoginScreen
  bool alreadyOnLogin = false;
  Navigator.popUntil(context, (route) {
    if (route.settings.name == 'login') {
      alreadyOnLogin = true;
    }
    return true;
  });
  if (alreadyOnLogin) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => LoginScreen(),
      settings: RouteSettings(name: 'login'),
    ),
    (route) => false,
  );
}

Future<void> showEndSessionMessage(BuildContext context) async {
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text("انتهت جلسة التسجيل")));
}

/// /// ✅ FIXED: Proper session validity check
/// The checkSessionValidaty works in two ways offline and online mode,
/// If you're in offline mode it will check the refresh token if valid or not "Still this thing has security concerns"
/// If the refresh invalid and offline then Get him to the home screen
/// If it's ok , so he wants to refresh again, so let him refresh
/// Checks session validity in both offline and online modes
/// Shows Arabic snackbar messages for different scenarios
///
/// Returns true if session is valid, false if user needs to login
Future<bool> checkSessionValidity(
  BuildContext context,
  TokenService tokenService,
) async {
  debugPrint("Checking session validity...");

  // Step 1: Check local refresh token validity
  bool refreshValid = await tokenService.isRefreshTokenLocallyValid();

  if (!refreshValid) {
    debugPrint("Session invalid: refresh token or subscription expired");

    // Show Arabic snackbar for expired session
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى',
            style: TextStyle(
              fontFamily: 'Cairo',
            ), // Use Arabic font if available
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'حسناً',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      // Wait for snackbar to be visible
      await Future.delayed(const Duration(milliseconds: 500));
    }

    await goToLogin(context);
    return false;
  }

  debugPrint("Refresh token and subscription are valid locally");

  // Step 2: Try to refresh access token (online check)
  try {
    bool refreshed = await tokenService.refreshAccessToken();

    if (refreshed) {
      debugPrint("✅ Access token refreshed successfully (ONLINE)");

      // Optional: Show success message

      return true;
    } else {
      debugPrint(
        "⚠️ Could not refresh access token (OFFLINE or network error)",
      );

      // Show offline warning
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'أنت تعمل في وضع عدم الاتصال. بعض الميزات قد لا تكون متاحة',
              style: TextStyle(fontFamily: 'Cairo'),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'فهمت',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }

      // Allow offline usage since local tokens are still valid
      return true;
    }
  } catch (e) {
    debugPrint("⚠️ Refresh attempt failed: $e (assuming OFFLINE mode)");

    // Show offline mode message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'لا يوجد اتصال بالإنترنت. يمكنك الاستمرار في وضع عدم الاتصال',
            style: TextStyle(fontFamily: 'Cairo'),
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'حسناً',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }

    // Local tokens are valid, allow offline usage
    return true;
  }
}
