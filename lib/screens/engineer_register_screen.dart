import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/RegisterController.dart';
import '../helpers/ServiceLocator.dart';
import '../models/RegisterClass.dart';

class EngineerRegisterScreen extends StatefulWidget {
  const EngineerRegisterScreen({super.key});

  @override
  State<EngineerRegisterScreen> createState() => _EngineerRegisterScreenState();
}

class _EngineerRegisterScreenState extends State<EngineerRegisterScreen> {
  final registerController = getIt<RegisterController>();
  File? _imageFile;
  final picker = ImagePicker();

  // Session storage
  static Map<String, dynamic>? sessionEngineerData;
  static File? sessionImage;
  // User type: 0 = Contractor, 1 = Engineer
  int userTypeIndex = 1;
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _bioController = TextEditingController();
  final _referralController = TextEditingController();
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (sessionEngineerData != null) {
      _firstNameController.text = sessionEngineerData!['firstName'] ?? '';
      _lastNameController.text = sessionEngineerData!['lastName'] ?? '';
      _emailController.text = sessionEngineerData!['email'] ?? '';
      _mobileController.text = sessionEngineerData!['phoneNumber'] ?? '';
      _specializationController.text =
          sessionEngineerData!['specialization'] ?? '';
      _salaryController.text = sessionEngineerData!['pay']?.toString() ?? '';
      _bioController.text = sessionEngineerData!['bio'] ?? '';
      _governorateController.text = sessionEngineerData!['governorate'] ?? '';
      _cityController.text = sessionEngineerData!['city'] ?? '';
      _districtController.text = sessionEngineerData!['district'] ?? '';
      _passwordController.text = sessionEngineerData!['password'] ?? '';
      _referralController.text = sessionEngineerData!['referralCode'] ?? '';
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

  Future<void> _registerEngineer() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _toast("كلمات المرور غير متطابقة");
      return;
    }

    final user = RegisterUserDto(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _mobileController.text.trim(),
      password: _passwordController.text.trim(),
      providerType: userTypeIndex == 0 ? "Contractor" : "Engineer",
      specialization: _specializationController.text.trim(),
      workerType: 1,
      pay: double.tryParse(_salaryController.text.trim()) ?? 0,
      bio: _bioController.text.trim(),
      referralUserName: _referralController.text.trim(),
      governorate: _governorateController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
    );

    // Save session
    sessionEngineerData = {
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'specialization': user.specialization,
      'pay': user.pay,
      'bio': user.bio,
      'governorate': user.governorate,
      'city': user.city,
      'district': user.district,
      'password': user.password,
      'providerType': user.providerType,
      'referralCode': user.referralUserName,
    };

    if (await registerController.registerUser(user, _imageFile) == true) {
      _toast("تم تسجيل بياناتك بنجاح");
      Navigator.pop(context);
    } else {
      _toast("حدث خطأ يرجي اعادة التسجيل");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تسجيل مقاول/مهندس',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7FAFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey[100],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : null,
                child: _imageFile == null
                    ? const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF13A9F6),
                        size: 32,
                      )
                    : null,
              ),
            ),
            TextButton(onPressed: _pickImage, child: const Text('رفع صورة')),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    title: const Text('مقاول'),
                    value: 0,
                    groupValue: userTypeIndex,
                    onChanged: (val) => setState(() => userTypeIndex = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<int>(
                    title: const Text('مهندس'),
                    value: 1,
                    groupValue: userTypeIndex,
                    onChanged: (val) => setState(() => userTypeIndex = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الاول',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الاخير',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'البريد الالكتروني',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'رقم الجوال',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _specializationController,
              decoration: const InputDecoration(
                labelText: 'التخصص',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الأجر',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _bioController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'نبذة عنك',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _referralController,
              decoration: const InputDecoration(
                labelText: 'كيف عرفت هذا التطبيق؟',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            // Location fields
            TextFormField(
              controller: _governorateController,
              decoration: const InputDecoration(
                labelText: 'المحافظة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'المدينة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: 'الحي',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registerEngineer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13A9F6),
                ),
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
