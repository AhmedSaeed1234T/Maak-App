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
      settings: const RouteSettings(name: 'login'),
    ),
    (route) => false,
  );
}

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
                  goToLogin(context);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى',
              style: TextStyle(fontFamily: 'Cairo'),
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

        await Future.delayed(const Duration(milliseconds: 500));
      }

      await goToLogin(context);
    }

    return false;
  }

  // ✅ Session is valid - no need to show anything
  debugPrint("✅ Session valid");
  return true;
}
