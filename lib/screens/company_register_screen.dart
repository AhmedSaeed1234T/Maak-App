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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "تسجيل شركة/متجر",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey[200],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : null,
                child: _imageFile == null
                    ? const Icon(Icons.camera_alt, size: 32, color: Colors.blue)
                    : null,
              ),
            ),
            TextButton(
              onPressed: _pickImage,
              child: const Text("رفع شعار/صورة الشركة"),
            ),

            const SizedBox(height: 16),
            // Business and owner
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "اسم الشركة/المؤسسة",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ownerController,
              decoration: const InputDecoration(
                labelText: "اسم المالك",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _businessController,
              decoration: const InputDecoration(
                labelText: "اسم التخصص",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "البريد الإلكتروني",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: "رقم الجوال",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _referralController,
              decoration: const InputDecoration(
                labelText: "كيف عرفت هذا التطبيق؟",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    title: const Text('شركة'),
                    value: 0,
                    groupValue: userTypeIndex,
                    onChanged: (val) => setState(() => userTypeIndex = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<int>(
                    title: const Text('سوق'),
                    value: 1,
                    groupValue: userTypeIndex,
                    onChanged: (val) => setState(() => userTypeIndex = val!),
                  ),
                ),
              ],
            ),

            // Location fields
            TextFormField(
              controller: _governorateController,
              decoration: const InputDecoration(
                labelText: "المحافظة",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: "المدينة",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: "الحي",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Bio
            TextFormField(
              controller: _bioController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "نبذة عن الشركة",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Passwords
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "كلمة المرور",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "تأكيد كلمة المرور",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registerCompany,
                child: const Text("حفظ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
