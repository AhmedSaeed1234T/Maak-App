import 'package:flutter/material.dart';

class PaymentFailureScreen extends StatelessWidget {
  final int? paymentId;
  final String? userId;
  final double? amount;
  final String? error;

  const PaymentFailureScreen({
    super.key,
    this.paymentId,
    this.userId,
    this.amount,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    const errorColor = Color(0xFFE74C3C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Failure Icon with Shadow
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF1948A), Color(0xFFE74C3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: errorColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(40),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Main Title
            const Text(
              'فشلت عملية الدفع',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const Text(
                    'عذراً، لم نتمكن من إتمام عملية الدفع الخاصة بك. يرجى المحاولة مرة أخرى أو استخدام طريقة دفع أخرى.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.6,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  if (error != null && error!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'التفاصيل: $error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE74C3C),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(flex: 3),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'المحاولة مرة أخرى',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/dashboard',
                      (route) => false,
                    ),
                    child: const Text(
                      'العودة للرئيسية',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
