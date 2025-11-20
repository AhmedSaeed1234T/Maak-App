import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  static File? sessionImage;
  static Map<String, String> sessionUser = {
    'name': '',
    'email': '',
    'address': '',
    'password': '',
  };
  File? _imageFile;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hidePassword = true;

  InputDecoration _buildDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF13A9F6)),
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

  @override
  void initState() {
    super.initState();
    _imageFile = sessionImage;
    _nameController.text = sessionUser['name'] ?? '';
    _emailController.text = sessionUser['email'] ?? '';
    _addressController.text = sessionUser['address'] ?? '';
    _passwordController.text = sessionUser['password'] ?? '';
  }
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Header Icon
            Container(
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
              child: const Icon(Icons.person_add, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              "إنشاء حساب جديد",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "الاشتراك مجاني وسهل",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 28),
            // Profile Image Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _imageFile = File(pickedFile.path);
                          sessionImage = _imageFile;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.15),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFFF4F7FA),
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null ? Icon(Icons.camera_alt, size: 40, color: primary) : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'انقر لتحميل صورة شخصية',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _imageFile = File(pickedFile.path);
                          sessionImage = _imageFile;
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("تغيير الصورة"),
                    style: TextButton.styleFrom(
                      foregroundColor: primary,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Form Fields
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الاسم مطلوب';
                      }
                      return null;
                    },
                    decoration: _buildDecoration('الاسم', Icons.person),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'البريد الإلكترونى مطلوب';
                      }
                      return null;
                    },
                    decoration: _buildDecoration('البريد الإلكترونى', Icons.email),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'العنوان مطلوب';
                      }
                      return null;
                    },
                    decoration: _buildDecoration('العنوان', Icons.location_on),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'كلمة المرور مطلوبة';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF13A9F6)),
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF13A9F6),
                        ),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Register Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  _RegisterScreenState.sessionUser['name'] = _nameController.text;
                  _RegisterScreenState.sessionUser['email'] = _emailController.text;
                  _RegisterScreenState.sessionUser['address'] = _addressController.text;
                  _RegisterScreenState.sessionUser['password'] = _passwordController.text;
                  _RegisterScreenState.sessionUser['accountType'] = 'user';
                  sessionImage = _imageFile;
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('إنشاء حساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('لديك حساب بالفعل؟ ', style: TextStyle(fontSize: 14, color: Colors.black87)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('سجّل دخول', style: TextStyle(color: Color(0xFF13A9F6), fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
