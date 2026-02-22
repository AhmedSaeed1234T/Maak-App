import 'dart:io';
import 'package:abokamall/controllers/LoginController.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/RegisterController.dart';
import '../helpers/ServiceLocator.dart';
import '../models/RegisterClass.dart';
import '../widgets/location_fields.dart';

class EngineerRegisterScreen extends StatefulWidget {
  const EngineerRegisterScreen({super.key});

  @override
  State<EngineerRegisterScreen> createState() => _EngineerRegisterScreenState();
}

class _EngineerRegisterScreenState extends State<EngineerRegisterScreen> {
  final registerController = getIt<RegisterController>();
  final loginController = getIt<LoginController>();

  File? _imageFile;
  final picker = ImagePicker();
  bool isRegistering = false;

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
  final _derivedSpecController = TextEditingController();
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  String? _selectedGovernorate;
  String? _selectedCity;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      sessionImage = _imageFile;
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    CustomSnackBar.show(context, message: msg, type: SnackBarType.info);
  }

  Future<void> _registerEngineer() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _toast("يرجى ملء جميع الحقول المطلوبة");
      return;
    }
    // Validation for derivedSpec if userType is Engineer (1)
    if (userTypeIndex == 1 && _derivedSpecController.text.trim().isEmpty) {
      _toast("يرجى إدخال التخصص الفرعي");
      return;
    }
    if (_imageFile == null) {
      _toast("يرجى اختيار صورة للملف الشخصي");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _toast("كلمات المرور غير متطابقة");
      return;
    }

    setState(() => isRegistering = true);

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
      derivedSpec: userTypeIndex == 1
          ? _derivedSpecController.text.trim()
          : null,
    );

    // Save session

    final result = await registerController.registerUser(user, _imageFile);

    if (!mounted) return; // Stop if user popped the page

    if (result.success) {
      final loginResult = await loginController.login(
        _mobileController.text,
        _passwordController.text,
      );

      if (!mounted) return; // Stop if user popped the page

      _toast("تم تسجيل بياناتك بنجاح");

      setState(() => isRegistering = false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false, // remove everything
      );
    } else {
      if (mounted) setState(() => isRegistering = false);
      _toast(result.arabicErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return WillPopScope(
      onWillPop: () async => !isRegistering,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'تسجيل مقاول/مهندس',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0.5,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.engineering,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'إنشاء حسابك',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أكمل بيانات تسجيلك الآن',
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
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : null,
                      child: _imageFile == null
                          ? Icon(Icons.camera_alt, color: primary, size: 38)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("اختر صورتك"),
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 28),

                // Main Card
                Card(
                  elevation: 2,
                  shadowColor: primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // User Type Selection
                        _buildSectionLabel('نوع الحساب'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile<int>(
                                  title: const Text(
                                    'مقاول',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  value: 0,
                                  groupValue: userTypeIndex,
                                  activeColor: primary,
                                  onChanged: (val) =>
                                      setState(() => userTypeIndex = val!),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  title: const Text(
                                    'مهندس',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  value: 1,
                                  groupValue: userTypeIndex,
                                  activeColor: primary,
                                  onChanged: (val) =>
                                      setState(() => userTypeIndex = val!),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Names
                        _buildSectionLabel('البيانات الشخصية *'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _firstNameController,
                                'الاسم الأول *',
                                Icons.person,
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                _lastNameController,
                                'الاسم الأخير *',
                                Icons.person,
                                isRequired: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _emailController,
                          'البريد الإلكتروني ',
                          Icons.email,
                          isRequired: false,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _mobileController,
                          'رقم الجوال *',
                          Icons.phone,
                          keyboardType: TextInputType.phone,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),

                        // Professional Info
                        _buildSectionLabel('معلومات مهنية'),
                        const SizedBox(height: 10),
                        _buildTextField(
                          _specializationController,
                          'التخصص *',
                          Icons.school,
                          isRequired: true,
                        ),
                        if (userTypeIndex == 1) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            _derivedSpecController,
                            'التخصص الفرعي *',
                            Icons.build,
                            isRequired: true,
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildTextField(
                          _salaryController,
                          'الأجر *',
                          Icons.monetization_on,
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextFieldMultiline(
                          _bioController,
                          'نبذة عنك',
                          Icons.description,
                          lines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _referralController,
                          'كيف عرفت هذا التطبيق؟',
                          Icons.share,
                        ),
                        const SizedBox(height: 20),

                        // Location
                        _buildSectionLabel('الموقع الجغرافي'),
                        const SizedBox(height: 10),
                        GovernorateDropdownField(
                          controller: _governorateController,
                          primaryColor: const Color(0xFF13A9F6),
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
                          primaryColor: const Color(0xFF13A9F6),
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
                          primaryColor: const Color(0xFF13A9F6),
                          isRequired: false,
                        ),
                        const SizedBox(height: 20),

                        // Passwords
                        _buildSectionLabel('كلمة المرور *'),
                        const SizedBox(height: 10),
                        _buildPasswordField(
                          _passwordController,
                          'كلمة المرور *',
                          isPassword: true,
                          isVisible: _isPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          _confirmPasswordController,
                          'تأكيد كلمة المرور *',
                          isPassword: false,
                          isVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          isRequired: true,
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _registerEngineer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
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
                                    'حفظ البيانات',
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

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF13A9F6)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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

  Widget _buildPasswordField(
    TextEditingController controller,
    String label, {
    bool isPassword = true,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              if (isPassword && value.length < 8) {
                return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF13A9F6)),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF13A9F6),
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
