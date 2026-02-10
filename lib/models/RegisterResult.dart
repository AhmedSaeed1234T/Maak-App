class RegisterResult {
  final bool success;
  final String? errorCode;
  final String? message;

  RegisterResult({required this.success, this.errorCode, this.message});

  /// Get Arabic error message based on error code
  String get arabicErrorMessage {
    if (errorCode == null) return message ?? 'حدث خطأ غير معروف';

    switch (errorCode) {
      case 'GeneralError':
        return 'حدث خطأ عام في التسجيل';
      case 'ReferralUserNotFound':
        return 'مستخدم الاحالة غير موجود يمكن ترك هذا الحقل فارغا';
      case 'PhoneNumberAlreadyExists':
        return 'رقم الهاتف موجود بالفعل';
      case 'EmailAlreadyExists':
        return 'البريد الإلكتروني موجود بالفعل';
      case 'ImageIsNull':
        return 'يرجى رفع صورة الملف الشخصي';
      case 'InvalidPaymentValue':
        return 'قيمة الدفع غير صحيحة';
      case 'InvalidInput':
        return 'هناك خطأ في البيانات المدخلة , اعد كتابتها بشكل سليم';
      case "PasswordInvalid":
        return 'يجب علي الاقل 8 حروف لكلمة المرور';
      case "EmailOrPasswordInCorrect":
        return 'الايميل او الباسورد خطأ, يرجي اعادة التأكد';
      default:
        return 'حدث خطأ في التسجيل: $errorCode';
    }
  }
}
