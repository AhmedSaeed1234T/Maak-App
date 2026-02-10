class ApiMessage {
  final String? message; // user-facing localized message
  final String? errorCode; // backend error code
  final bool success;

  ApiMessage({this.message, this.errorCode, required this.success});

  factory ApiMessage.fromJson(Map<String, dynamic> json) {
    final code = json['errorCode']?.toString();
    final serverMessage = json['message']?.toString();

    return ApiMessage(
      success: false,
      errorCode: code,
      message: _mapErrorMessage(code, serverMessage),
    );
  }

  static String _mapErrorMessage(String? code, String? fallback) {
    switch (code) {
      case "GeneralError":
        return "حدث خطأ غير متوقع";

      case "ReferralUserNotFound":
        return "المستخدم المُحيل غير موجود";

      case "PhoneNumberAlreadyExists":
        return "رقم الهاتف مستخدم بالفعل";

      case "EmailAlreadyExists":
        return "البريد الإلكتروني مستخدم بالفعل";

      case "InvalidEmail":
        return "البريد الإلكتروني غير صالح";

      case "InvalidPhoneNumber":
        return "رقم الهاتف غير صالح";

      case "InvalidPaymentValue":
        return "قيمة الخدمة غير صالحة";

      case "ImageIsNull":
        return "يجب رفع صورة شخصية";

      case "SubscriptionInvalid":
        return "لقد انتهي اشتراكك";

      case "InvalidInput":
        return "البيانات المدخلة غير صحيحة";

      case "UserIsNotFound":
        return "المستخدم غير موجود";

      case "PasswordInvalid":
        return "كلمة المرور غير صحيحة";

      case "EmailOrPasswordInCorrect":
        return "البريد الإلكتروني أو كلمة المرور غير صحيحة";

      case "RefreshTokenInvalid":
        return "جلسة الدخول غير صالحة، برجاء تسجيل الدخول مرة أخرى";

      default:
        return fallback ?? "حدث خطأ غير معروف";
    }
  }
}
