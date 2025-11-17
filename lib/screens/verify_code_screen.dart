import 'package:flutter/material.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({Key? key}) : super(key: key);
  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}
class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('تأكيد الكود', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0),
        child: Column(
          children: [
            const SizedBox(height: 36),
            const Text(
              'أدخل رقم هاتفك والكود المرسل لإعادة تعيين كلمة المرور.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (val) {},
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6)),
                    onPressed: () {
                    },
                    child: const Text('SMS'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'كود التحقق',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6), textStyle: const TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.pushNamed(context, '/reset_password');
                },
                child: const Text('تأكيد الكود'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
