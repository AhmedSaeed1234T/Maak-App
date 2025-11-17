import 'dart:io';
import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/RegisterController.dart';
import '../helpers/ServiceLocator.dart';
import '../models/RegisterClass.dart';

class WorkerRegisterScreen extends StatefulWidget {
  const WorkerRegisterScreen({super.key});

  @override
  State<WorkerRegisterScreen> createState() => _WorkerRegisterScreenState();
}

class _WorkerRegisterScreenState extends State<WorkerRegisterScreen> {
  final registerController = getIt<RegisterController>();
  final _formKey = GlobalKey<FormState>();

  // Image
  File? _imageFile;
  final picker = ImagePicker();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _jobController = TextEditingController();
  final _salaryController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _referralController = TextEditingController(); // New referral code

  String salaryType = "daily"; // daily = 0, fixed = 1
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  // Pick image
  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  // Get current location

  // Show simple toast
  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Register worker
  Future<void> _registerWorker() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _toast("كلمات المرور غير متطابقة");
      return;
    }

    final loc = await getCurrentLocation();
    if (loc == null) return; // Stop if location not available

    final user = RegisterUserDto(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      district: _locationController.text.trim(),
      providerType: "Worker",
      skill: _jobController.text.trim(),
      workerType: salaryType == "daily" ? 0 : 1,
      pay: double.tryParse(_salaryController.text.trim()) ?? 0,
      bio: _bioController.text.trim(),
      referralUserName: _referralController.text.trim(), // Added referral
    );

    final ok = await registerController.registerUser(user, _imageFile);

    if (ok == true) {
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
        title: const Text("تسجيل عامل"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt,
                          size: 32, color: Colors.blue)
                      : null,
                ),
              ),
              TextButton(onPressed: _pickImage, child: const Text("رفع صورة")),
              const SizedBox(height: 16),

              // Name fields
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "الاسم الاول مطلوب"
                          : null,
                      decoration: const InputDecoration(
                        labelText: "الاسم الاول",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "الاسم الاخير مطلوب"
                          : null,
                      decoration: const InputDecoration(
                        labelText: "الاسم الاخير",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Email & phone
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.trim().isEmpty
                    ? "البريد الالكتروني مطلوب"
                    : null,
                decoration: const InputDecoration(
                  labelText: "البريد الالكتروني",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "رقم الجوال",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Job & salary type
              TextFormField(
                controller: _jobController,
                decoration: const InputDecoration(
                  labelText: "المهنة",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text("يومي"),
                      value: "daily",
                      groupValue: salaryType,
                      onChanged: (v) => setState(() => salaryType = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text("مقطوعية"),
                      value: "fixed",
                      groupValue: salaryType,
                      onChanged: (v) => setState(() => salaryType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "الأجر",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "نبذة عنك",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Referral code
              TextFormField(
                controller: _referralController,
                decoration: const InputDecoration(
                  labelText: " كيف عرفت هذا التطبيق؟",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "الموقع",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // Password
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
                  labelText: "كلمة المرور",
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
                  labelText: "تأكيد كلمة المرور",
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
              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    _registerWorker();
                  },
                  child: const Text("حفظ"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
