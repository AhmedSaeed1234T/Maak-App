import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class SearchResult {
  bool isSuccess;
  String? errorCode;
  String? errorMessage;
  String? lastDate;

  SearchResult({
    this.isSuccess = false,
    this.errorCode,
    this.errorMessage,
    this.lastDate,
  });

  Future<String> get arabicErrorMessage async {
    if (errorCode == null) return errorMessage ?? 'حدث خطأ غير معروف';
    switch (errorCode) {
      case 'GeneralError':
        return 'حدث خطأ عام أثناء تسجيل الدخول';
      case 'SubscriptionInvalid':
        if (lastDate != null) {
          try {
            final date = await getCurrentUserSubscription();
            final formattedDate = DateFormat('dd/MM/yyyy').format(date!);
            debugPrint("Format is $formattedDate");

            return "انتهى اشتراكك في $formattedDate، يرجى التجديد";
          } catch (e) {
            return "انتهى اشتراكك، يرجى التجديد";
          }
        }
        return "انتهى اشتراكك، يرجى التجديد";
      default:
        return errorMessage ?? 'حدث خطأ: $errorCode';
    }
  }
}
