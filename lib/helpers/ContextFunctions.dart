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

/// ✅ FIXED: Proper session validity check
Future<bool> checkSessionValidity(
  BuildContext context,
  TokenService tokenService,
) async {
  debugPrint("Checking session validity...");

  // 1. Check if refresh token is valid (checks both token expiry and subscription)
  bool refreshValid = await tokenService.isRefreshTokenLocallyValid();
  if (!refreshValid) {
    debugPrint("Session invalid: refresh token or subscription expired");
    await showEndSessionMessage(context);
    await goToLogin(context);
    return false;
  }
  debugPrint("Refresh token and subscription are valid");

  // 2. Try to refresh access token online (if possible)
  bool refreshed = await tokenService.refreshAccessToken();
  if (!refreshed) {
    debugPrint("Could not refresh access token (offline or network error)");
    // Allow offline usage if subscription is still valid
  } else {
    debugPrint("Access token refreshed successfully");
  }

  return true; // Session is valid
}
