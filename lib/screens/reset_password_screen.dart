import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _hidePass = true;
  bool _hideConfirm = true;
  String? errorText;
  
  void _checkAndSubmit() {
    if(_passController.text != _confirmController.text) {
      setState(() { errorText = 'كلمة المرور غير متطابقة'; });
    } else {
      setState(() { errorText = null; });
      Navigator.pushReplacementNamed(context, '/reset_success');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('إعادة تعيين كلمة المرور', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          children: [
            const SizedBox(height: 28),
            const Text('يجب أن تكون كلمة المرور الجديدة مختلفة عن السابقة.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 35),
            TextField(
              controller: _passController,
              obscureText: _hidePass,
              decoration: InputDecoration(
                labelText: 'كلمة مرور جديدة',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_hidePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() {_hidePass = !_hidePass;}),
                ),
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _confirmController,
              obscureText: _hideConfirm,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_hideConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() {_hideConfirm = !_hideConfirm;}),
                ),
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Text(errorText!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6)),
                onPressed: _checkAndSubmit,
                label: const Text('تأكيد'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
