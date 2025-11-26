import 'package:abokamall/helpers/supportPhone.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsapp(BuildContext context) async {
  final webUrl = Uri.parse('https://wa.me/$supportPhoneNumber');
  try {
    if (!await launchUrl(webUrl, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح الواتساب')));
    }
  } catch (_) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تعذر فتح الواتساب')));
  }
}
