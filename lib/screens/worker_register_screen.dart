import 'dart:io';
import 'package:abokamall/controllers/LoginController.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/RegisterController.dart';
import '../helpers/ServiceLocator.dart';
import '../models/RegisterClass.dart';
import '../widgets/location_fields.dart';

class WorkerRegisterScreen extends StatefulWidget {
  const WorkerRegisterScreen({super.key});
  @override
  State<WorkerRegisterScreen> createState() => _WorkerRegisterScreenState();
}

class _WorkerRegisterScreenState extends State<WorkerRegisterScreen> {
  final registerController = getIt<RegisterController>();
  final loginController = getIt<LoginController>();

  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF13A9F6);

  bool isRegistering = false;
  File? _imageFile;
  final picker = ImagePicker();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _jobController = TextEditingController();
  final _salaryController = TextEditingController();
  final _bioController = TextEditingController();
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  String? _selectedGovernorate;
  String? _selectedCity;
  final _referralController = TextEditingController();
  final _marketplaceController = TextEditingController();
  final _derivedSpecController = TextEditingController();

  String providerType = "Worker";
  String salaryType = "daily";
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  InputDecoration _buildDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryColor),
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
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    CustomSnackBar.show(context, message: msg, type: SnackBarType.info);
  }

  Future<void> _registerWorker() async {
    if (!_formKey.currentState!.validate()) {
      _toast("يرجى ملء جميع الحقول المطلوبة");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _toast("كلمات المرور غير متطابقة");
      return;
    }
    if (_imageFile == null) {
      _toast("يرجى اختيار صورة للملف الشخصي");
      return;
    }
    setState(() => isRegistering = true);

    final user = RegisterUserDto(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      district: _districtController.text.trim(),
      governorate: _governorateController.text.trim(),
      city: _cityController.text.trim(),
      providerType: providerType,
      skill: _jobController.text.trim(),
      workerType: salaryType == "daily" ? 0 : 1,
      pay: double.tryParse(_salaryController.text.trim()) ?? 0,
      bio: _bioController.text.trim(),

      referralUserName: _referralController.text.trim(),
      marketplace: _marketplaceController.text.trim(),
      derivedSpec: _derivedSpecController.text.trim(),
    );

    final result = await registerController.registerUser(user, _imageFile);

    if (!mounted) return;

    if (result.success) {
      final loginResult = await loginController.login(
        _phoneController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      _toast("تم تسجيل بياناتك بنجاح");

      setState(() => isRegistering = false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    } else {
      if (mounted) setState(() => isRegistering = false);
      _toast(result.arabicErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isRegistering,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تسجيل مقدم خدمة"),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        backgroundColor: const Color(0xFFF5F7FA),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF13A9F6).withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : null,
                      backgroundColor: const Color(0xFFE8F4FF),
                      child: _imageFile == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Color(0xFF13A9F6),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'انقر لتغيير الصورة',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("اختر صورتك"),
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryColor,
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 28),

                Card(
                  elevation: 8,
                  shadowColor: const Color(0xFF13A9F6).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'معلومات الحساب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? "الاسم الاول مطلوب"
                                    : null,
                                decoration: _buildDecoration(
                                  "الاسم الاول",
                                  Icons.person,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? "الاسم الاخير مطلوب"
                                    : null,
                                decoration: _buildDecoration(
                                  "الاسم الاخر",
                                  Icons.person,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => null,
                          decoration: _buildDecoration(
                            "البريد الالكتروني",
                            Icons.email,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phoneController,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "رقم الجوال مطلوب"
                              : null,
                          keyboardType: TextInputType.phone,
                          decoration: _buildDecoration(
                            "رقم الجوال",
                            Icons.phone,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _jobController,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "المهنة مطلوبة"
                              : null,
                          decoration: _buildDecoration("المهنة", Icons.work),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _marketplaceController,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "المحلات مطلوب"
                              : null,
                          decoration: _buildDecoration("سوق العماله ", Icons.store),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _derivedSpecController,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "التخصص الفرعي مطلوب"
                              : null,
                          decoration: _buildDecoration(
                            "التخصص الفرعي",
                            Icons.build,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  title: const Text("صنايعى"),
                                  value: "Worker",
                                  groupValue: providerType,
                                  onChanged: (v) =>
                                      setState(() => providerType = v!),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  title: const Text("مساعد"),
                                  value: "Assistant",
                                  groupValue: providerType,
                                  onChanged: (v) =>
                                      setState(() => providerType = v!),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (providerType == "Worker") ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: RadioListTile(
                                    title: const Text("يومي"),
                                    value: "daily",
                                    groupValue: salaryType,
                                    onChanged: (v) =>
                                        setState(() => salaryType = v!),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile(
                                    title: const Text("مقطوعية"),
                                    value: "fixed",
                                    groupValue: salaryType,
                                    onChanged: (v) =>
                                        setState(() => salaryType = v!),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _salaryController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "الأجر مطلوب"
                              : null,
                          decoration: _buildDecoration(
                            "الأجر",
                            Icons.monetization_on,
                          ).copyWith(hintText: 'مثال: 100'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _bioController,
                          maxLines: 3,
                          decoration: _buildDecoration(
                            "نبذة عنك",
                            Icons.description,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _referralController,
                          decoration: _buildDecoration(
                            "كيف عرفت هذا التطبيق؟",
                            Icons.share,
                          ),
                        ),
                        const SizedBox(height: 16),

                        GovernorateDropdownField(
                          controller: _governorateController,
                          primaryColor: _primaryColor,
                          isRequired: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedGovernorate = value;
                              _selectedCity = null;
                              _cityController.clear();
                              _districtController.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        CityDropdownField(
                          controller: _cityController,
                          selectedGovernorate: _selectedGovernorate,
                          primaryColor: _primaryColor,
                          isRequired: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                              _districtController.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        DistrictDropdownField(
                          controller: _districtController,
                          selectedGovernorate: _selectedGovernorate,
                          selectedCity: _selectedCity,
                          primaryColor: _primaryColor,
                          isRequired: false,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "كلمة المرور مطلوبة";
                            }
                            if (v.length < 8) {
                              return "كلمة المرور يجب ألا تقل عن 8 أحرف";
                            }
                            return null;
                          },
                          decoration:
                              _buildDecoration(
                                "كلمة المرور",
                                Icons.lock,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                ),
                              ),
                        ),
                        const SizedBox(height: 16),

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
                          decoration:
                              _buildDecoration(
                                "تأكيد كلمة المرور",
                                Icons.lock,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hideConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hideConfirmPassword =
                                          !_hideConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF13A9F6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              _registerWorker();
                            },
                            child: isRegistering
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "حفظ البيانات ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
