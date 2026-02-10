import 'package:intl/intl.dart';

class LoginResult {
  bool isSuccess;
  String? errorCode;
  String? errorMessage;
  String? lastDate; // ✅ This will be "2024-12-30" format (Egypt date)

  LoginResult({
    this.isSuccess = false,
    this.errorCode,
    this.errorMessage,
    this.lastDate,
  });

  String get arabicErrorMessage {
    if (errorCode == null) return errorMessage ?? 'حدث خطأ غير معروف';

    switch (errorCode) {
      case 'GeneralError':
        return 'حدث خطأ عام أثناء تسجيل الدخول';

      case 'SubscriptionInvalid':
        // ✅ Format the date nicely for Arabic display
        if (lastDate != null) {
          try {
            final date = DateTime.parse(lastDate!);
            final formattedDate = DateFormat('dd/MM/yyyy').format(date);
            return "انتهى اشتراكك في $formattedDate، يرجى التجديد";
          } catch (e) {
            return "انتهى اشتراكك، يرجى التجديد";
          }
        }
        return "انتهى اشتراكك، يرجى التجديد";
      case "EmailOrPasswordInCorrect":
        return 'الايميل او الباسورد خطأ, يرجي اعادة التأكد';
      default:
        return errorMessage ?? 'حدث خطأ: $errorCode';
    }
  }
}
