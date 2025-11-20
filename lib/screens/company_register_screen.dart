import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/RegisterController.dart';
import '../helpers/ServiceLocator.dart';
import '../models/RegisterClass.dart';

class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  final registerController = getIt<RegisterController>();
  File? _imageFile;
  final picker = ImagePicker();

  static Map<String, dynamic>? sessionCompanyData;
  static File? sessionImage;

  int userTypeIndex = 0; 

  // Controllers
  final _businessController = TextEditingController();
  final _ownerController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _referralController = TextEditingController();
  final _nameController = TextEditingController();
  // Location controllers
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (sessionCompanyData != null) {
      _nameController.text = sessionCompanyData!['name'] ?? '';
      _businessController.text = sessionCompanyData!['business'] ?? '';
      _ownerController.text = sessionCompanyData!['owner'] ?? '';
      _emailController.text = sessionCompanyData!['email'] ?? '';
      _mobileController.text = sessionCompanyData!['phoneNumber'] ?? '';
      _bioController.text = sessionCompanyData!['bio'] ?? '';
      _passwordController.text = sessionCompanyData!['password'] ?? '';
      _referralController.text = sessionCompanyData!['referralUserName'] ?? '';
      _governorateController.text = sessionCompanyData!['governorate'] ?? '';
      _cityController.text = sessionCompanyData!['city'] ?? '';
      _districtController.text = sessionCompanyData!['district'] ?? '';
    }
    _imageFile = sessionImage;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      sessionImage = _imageFile;
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _registerCompany() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _toast("كلمات المرور غير متطابقة");
      return;
    }

    final company = RegisterUserDto(
      firstName: _nameController.text.trim(), // Business Name
      email: _emailController.text.trim(),
      phoneNumber: _mobileController.text.trim(),
      password: _passwordController.text.trim(),
      providerType: userTypeIndex == 0 ? "Company" : "Marketplace",

      governorate: _governorateController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      business: _businessController.text.trim(),
      owner: _ownerController.text.trim(),
      bio: _bioController.text.trim(),
      referralUserName: _referralController.text.trim(),
    );

    // Save session
    sessionCompanyData = {
      'business': company.business,
      'owner': company.owner,
      'email': company.email,
      'phoneNumber': company.phoneNumber,
      'bio': company.bio,
      'password': company.password,
      'referralUserName': company.referralUserName,
      'providerType': company.providerType,
      'governorate': _governorateController.text,
      'city': _cityController.text,
      'district': _districtController.text,
      'name': _nameController.text,
    };

    final ok = await registerController.registerUser(company, _imageFile);
    if (ok == true) {
      _toast("تم تسجيل بياناتك بنجاح");
      Navigator.pop(context);
    } else {
      _toast("حدث خطأ يرجى إعادة التسجيل");
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "تسجيل شركة/متجر",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with Icon
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
                boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.business, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'إنشاء حساب الشركة',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'أكمل بيانات شركتك الآن',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 28),
            
            // Profile Image
            GestureDetector(
              onTap: _pickImage,
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
                  radius: 55,
                  backgroundColor: Color(0xFFF4F7FA),
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(Icons.business, color: primary, size: 38)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text("اختر شعار الشركة"),
              style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 28),

            // Main Card
            Card(
              elevation: 2,
              shadowColor: primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Business Type Selection
                    _buildSectionLabel('نوع الحساب'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('شركة', style: TextStyle(fontSize: 14, color: Colors.black87)),
                              value: 0,
                              groupValue: userTypeIndex,
                              activeColor: primary,
                              onChanged: (val) => setState(() => userTypeIndex = val!),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              dense: true,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('متجر', style: TextStyle(fontSize: 14, color: Colors.black87)),
                              value: 1,
                              groupValue: userTypeIndex,
                              activeColor: primary,
                              onChanged: (val) => setState(() => userTypeIndex = val!),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Business Info
                    _buildSectionLabel('معلومات الشركة'),
                    const SizedBox(height: 10),
                    _buildTextField(_nameController, "اسم الشركة/المؤسسة", Icons.business),
                    const SizedBox(height: 16),
                    _buildTextField(_ownerController, "اسم المالك", Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(_businessController, "اسم التخصص", Icons.work),
                    const SizedBox(height: 20),

                    // Contact Info
                    _buildSectionLabel('معلومات الاتصال'),
                    const SizedBox(height: 10),
                    _buildTextField(_emailController, "البريد الإلكتروني", Icons.email),
                    const SizedBox(height: 16),
                    _buildTextField(_mobileController, "رقم الجوال", Icons.phone, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildTextFieldMultiline(_bioController, "نبذة عن الشركة", Icons.description, lines: 3),
                    const SizedBox(height: 16),
                    _buildTextField(_referralController, "كيف عرفت هذا التطبيق؟", Icons.share),
                    const SizedBox(height: 20),

                    // Location
                    _buildSectionLabel('الموقع الجغرافي'),
                    const SizedBox(height: 10),
                    _buildTextField(_governorateController, "المحافظة", Icons.location_on),
                    const SizedBox(height: 16),
                    _buildTextField(_cityController, "المدينة", Icons.location_city),
                    const SizedBox(height: 16),
                    _buildTextField(_districtController, "الحي", Icons.location_on_outlined),
                    const SizedBox(height: 20),

                    // Passwords
                    _buildSectionLabel('كلمة المرور'),
                    const SizedBox(height: 10),
                    _buildPasswordField(_passwordController, "كلمة المرور"),
                    const SizedBox(height: 16),
                    _buildPasswordField(_confirmPasswordController, "تأكيد كلمة المرور"),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _registerCompany,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: const Text('حفظ البيانات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF13A9F6)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      ),
    );
  }

  Widget _buildTextFieldMultiline(
    TextEditingController controller,
    String label,
    IconData icon, {
    int lines = 3,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      minLines: lines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Icon(icon, color: const Color(0xFF13A9F6)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF13A9F6)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      ),
    );
  }
}
