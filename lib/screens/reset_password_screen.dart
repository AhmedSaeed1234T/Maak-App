import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/apiroute.dart';
import '../helpers/ServiceLocator.dart';
import '../helpers/TokenService.dart';
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}
class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  InputDecoration _buildDecoration(String label, IconData icon, bool hidePassword, VoidCallback onToggle) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF13A9F6)),
      suffixIcon: IconButton(
        icon: Icon(
          hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: const Color(0xFF13A9F6),
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF13A9F6), width: 2),
      ),
    );
  }

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final tokenService = getIt<TokenService>();
    final accessToken = await tokenService.getAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("المستخدم غير مسجل دخول")));
      setState(() => isLoading = false);
      return;
    }
    final url = Uri.parse('$apiRoute/auth/change-password');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'currentPassword': currentPasswordController.text.trim(),
        'newPassword': newPasswordController.text.trim(),
        'confirmPassword': confirmPasswordController.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
      );
      Navigator.pop(context); 
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'حدث خطأ أثناء تغيير كلمة المرور'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تغيير كلمة المرور'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Header Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 12, offset: Offset(0, 6))],
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'تغيير كلمة المرور',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل كلمة المرور الحالية وكلمة المرور الجديدة',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Current Password
              TextFormField(
                controller: currentPasswordController,
                obscureText: _hideCurrentPassword,
                decoration: _buildDecoration('كلمة المرور الحالية', Icons.lock, _hideCurrentPassword, () {
                  setState(() => _hideCurrentPassword = !_hideCurrentPassword);
                }),
                validator: (v) => v == null || v.trim().isEmpty ? 'كلمة المرور مطلوبة' : null,
              ),
              const SizedBox(height: 16),
              // New Password
              TextFormField(
                controller: newPasswordController,
                obscureText: _hideNewPassword,
                decoration: _buildDecoration('كلمة المرور الجديدة', Icons.lock_open, _hideNewPassword, () {
                  setState(() => _hideNewPassword = !_hideNewPassword);
                }),
                validator: (v) => v != null && v.length >= 6
                    ? null
                    : 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
              ),
              const SizedBox(height: 16),
              // Confirm Password
              TextFormField(
                controller: confirmPasswordController,
                obscureText: _hideConfirmPassword,
                decoration: _buildDecoration('تأكيد كلمة المرور', Icons.check_circle, _hideConfirmPassword, () {
                  setState(() => _hideConfirmPassword = !_hideConfirmPassword);
                }),
                validator: (v) => v != null && v == newPasswordController.text
                    ? null
                    : 'كلمة المرور غير متطابقة',
              ),
              const SizedBox(height: 28),
              // Change Password Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('تغيير كلمة المرور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
