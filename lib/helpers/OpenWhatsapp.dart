import 'package:abokamall/helpers/supportPhone.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsapp(BuildContext context) async {
  final webUrl = Uri.parse('https://wa.me/$supportPhoneNumber');
  try {
    if (!await launchUrl(webUrl, mode: LaunchMode.externalApplication)) {
      CustomSnackBar.show(
        context,
        message: 'تعذر فتح الواتساب',
        type: SnackBarType.error,
      );
    }
  } catch (_) {
    CustomSnackBar.show(
      context,
      message: 'تعذر فتح الواتساب',
      type: SnackBarType.error,
    );
  }
}
