import 'package:flutter/material.dart';

class ResetSuccessScreen extends StatelessWidget {
  const ResetSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Center(
            child: Container(
              decoration: const BoxDecoration(
                  color: Color(0xFFE6FAEC), shape: BoxShape.circle),
              padding: const EdgeInsets.all(35),
              child: const Icon(Icons.check, color: Color(0xFF4AE27D), size: 58),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'تمت إعادة تعيين كلمة المرور!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          const Text(
            'تم تغيير كلمة المرور الخاصة بك بنجاح. يمكنك الآن تسجيل الدخول بكلمتك الجديدة.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('العودة لتسجيل الدخول'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
