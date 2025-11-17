import 'dart:io';
import 'package:abokamall/helpers/HelperMethods.dart';
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
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final picker = ImagePicker();

  static Map<String, dynamic>? sessionCompanyData;
  static File? sessionImage;

  int userTypeIndex = 0; // 0 = Company, 1 = Commercial Store

  // Controllers
  final _referralController = TextEditingController();
  final _specializationController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _salaryController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    if (sessionCompanyData != null) {
      _referralController.text = sessionCompanyData!['referral'] ?? '';
      _specializationController.text =
          sessionCompanyData!['specialization'] ?? '';
      _businessNameController.text = sessionCompanyData!['businessName'] ?? '';
      _ownerNameController.text = sessionCompanyData!['ownerName'] ?? '';
      _emailController.text = sessionCompanyData!['email'] ?? '';
      _mobileController.text = sessionCompanyData!['mobile'] ?? '';
      _locationController.text = sessionCompanyData!['location'] ?? '';
      _bioController.text = sessionCompanyData!['bio'] ?? '';
      _passwordController.text = sessionCompanyData!['password'] ?? '';
      _salaryController.text = sessionCompanyData!['salary'] ?? '';
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
    if (_passwordController.text.isEmpty) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('كلمات المرور غير متطابقة')));
      return;
    }
    final loc = await getCurrentLocation();
    if (loc == null) {
      _toast("يرجى تفعيل خدمات الموقع");
      return;
    }
    final company = RegisterUserDto(
      firstName: _businessNameController.text,
      lastName: _ownerNameController.text,
      email: _emailController.text,
      phoneNumber: _mobileController.text,
      password: _passwordController.text,
      location: _locationController.text,
      lat: loc["lat"],
      lng: loc["lng"],
      userType: "SP",
      providerType: userTypeIndex == 0 ? "Company" : "Marketplace",
      business: _businessNameController.text,
      owner: _ownerNameController.text,
      workerType: 1,
      bio: _bioController.text,
      referralUserName: _referralController.text,
    );

    // Save session data
    sessionCompanyData = {
      'referral': _referralController.text,
      'specialization': _specializationController.text,
      'businessName': _businessNameController.text,
      'ownerName': _ownerNameController.text,
      'email': _emailController.text,
      'mobile': _mobileController.text,
      'location': _locationController.text,
      'bio': _bioController.text,
      'password': _passwordController.text,
      'providerType': company.providerType,
    };
    sessionImage = _imageFile;

    if (await registerController.registerUser(company, _imageFile) == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("تم تسجيل بياناتك بنجاح")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ يرجى إعادة التسجيل")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تسجيل شركة/متجر',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7FAFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[100],
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF13A9F6),
                          size: 32,
                        )
                      : null,
                ),
              ),
              TextButton(
                onPressed: _pickImage,
                child: const Text('رفع شعار/صورة الشركة'),
              ),
              const SizedBox(height: 16),

              // User type toggle
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
                      title: const Text('متجر تجاري'),
                      value: 1,
                      groupValue: userTypeIndex,
                      onChanged: (val) => setState(() => userTypeIndex = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Form fields
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'التخصص/مجال العمل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _businessNameController,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "اسم الشركة/المؤسسة مطلوب"
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'اسم الشركة/المؤسسة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ownerNameController,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "اسم المالك مطلوب"
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'اسم المالك',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.trim().isEmpty
                    ? "البريد الإلكتروني مطلوب"
                    : null,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الجوال',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referralController,
                decoration: const InputDecoration(
                  labelText: 'كيف عرفت هذا التطبيق',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'الموقع/العنوان',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _bioController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'نبذة عن الشركة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _hidePassword,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "كلمة المرور مطلوبة";
                  }
                  if (v.length < 6) {
                    return "كلمة المرور يجب ألا تقل عن 6 أحرف";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _hideConfirmPassword,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "تأكيد كلمة المرور مطلوب";
                  }
                  if (v != _passwordController.text) {
                    return "كلمات المرور غير متطابقة";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hideConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _hideConfirmPassword = !_hideConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    _registerCompany();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13A9F6),
                  ),
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
