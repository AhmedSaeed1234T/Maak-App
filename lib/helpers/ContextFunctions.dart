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
      settings: RouteSettings(name: 'login'), // give it a name
    ),
    (route) => false, // remove all previous routes
  );
}

Future<void> showEndSessionMessage(BuildContext context) async {
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text("انتهت جلسة التسجيل")));
}

Future<bool> checkSessionValidity(
  BuildContext context,
  TokenService tokenService,
) async {
  // 1. Check if refresh token is valid
  bool refreshValid = await tokenService.isRefreshTokenLocallyValid();
  debugPrint("soha1");
  if (!refreshValid) {
    // Offline or expired refresh token -> force login
    await showEndSessionMessage(context);
    await goToLogin(context);
    return false;
  }
  debugPrint("soha2");

  // 2. Refresh access token online (if possible)
  bool refreshed = await tokenService.refreshAccessToken();
  if (!refreshed) {
    // Optional: silently allow offline usage if subscription valid
    debugPrint(
      "Cannot refresh access token, but subscription may still allow offline usage",
    );
  }
  debugPrint("soha3");

  // 3. Check subscription expiry
  final expiryDate = await getCurrentUserSubscription();
  if (expiryDate == null ||
      expiryDate.add(Duration(days: 1)).isBefore(DateTime.now())) {
    await showEndSessionMessage(context);
    await goToLogin(context);
    return false;
  }

  return true; // everything ok
}
