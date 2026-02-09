import 'dart:io';
import 'package:abokamall/controllers/LoginController.dart';
import 'package:abokamall/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/RegisterController.dart';
import '../helpers/ServiceLocator.dart';
import '../models/RegisterClass.dart';

const Map<String, List<String>> _governorateCities = {
  'القاهرة': ['القاهرة'],
  'الجيزة': ['الجيزة', '6 أكتوبر', 'الشيخ زايد', 'حدائق أكتوبر', 'الحوامدية'],
  'الإسكندرية': ['الإسكندرية', 'برج العرب', 'برج العرب الجديدة'],
  'القليوبية': [
    'بنها',
    'شبرا الخيمة',
    'قليوب',
    'القناطر الخيرية',
    'الخانكة',
    'كفر شكر',
    'طوخ',
    'شبين القناطر',
    'العبور',
  ],
  'الدقهلية': [
    'المنصورة',
    'ميت غمر',
    'طلخا',
    'أجا',
    'منية النصر',
    'بني عبيد',
    'السنبلاوين',
    'شربين',
    'دكرنس',
    'المطرية',
    'بلقاس',
    'تمى الأمديد',
  ],
  'الشرقية': [
    'الزقازيق',
    'العاشر من رمضان',
    'بلبيس',
    'أبو كبير',
    'فاقوس',
    'منيا القمح',
    'الحسينية',
    'كفر صقر',
  ],
  'الغربية': [
    'طنطا',
    'المحلة الكبرى',
    'كفر الزيات',
    'زفتى',
    'السنطة',
    'بسيون',
    'قطور',
  ],
  'المنوفية': [
    'شبين الكوم',
    'السادات',
    'منوف',
    'قويسنا',
    'الباجور',
    'أشمون',
    'تلا',
    'بركة السبع',
  ],
  'كفر الشيخ': [
    'كفر الشيخ',
    'دسوق',
    'بلطيم',
    'فوه',
    'مطوبس',
    'الحامول',
    'سيدي سالم',
    'الرياض',
    'بيلا',
    'قلين',
  ],
  'البحيرة': [
    'دمنهور',
    'كفر الدوار',
    'رشيد',
    'إدكو',
    'أبو حمص',
    'أبو المطامير',
    'الدلنجات',
    'وادي النطرون',
    'المحمودية',
  ],
  'دمياط': [
    'دمياط',
    'دمياط الجديدة',
    'رأس البر',
    'فارسكور',
    'الزرقا',
    'كفر سعد',
    'كفر البطيخ',
  ],
  'بورسعيد': [
    'بورسعيد',
    'بورفؤاد',
  ],
  'الإسماعيلية': [
    'الإسماعيلية',
    'فايد',
    'التل الكبير',
    'القنطرة شرق',
    'القنطرة غرب',
    'أبو صوير',
    'القصاصين',
  ],
  'السويس': ['السويس'],
  'الفيوم': ['الفيوم'],
  'بني سويف': [
    'بني سويف',
    'بني سويف الجديدة',
    'إهناسيا',
    'الواسطي',
    'ببا',
    'سمسطا',
    'ناصر',
  ],
  'المنيا': [
    'المنيا',
    'المنيا الجديدة',
    'ملوي',
    'سمالوط',
    'بني مزار',
    'مغاغة',
    'مطاي',
  ],
  'أسيوط': [
    'أسيوط',
    'أسيوط الجديدة',
    'ديروط',
    'منفلوط',
    'القوصية',
    'أبوتيج',
    'صدفا',
    'الغنايم',
    'ساحل سليم',
    'الفتح',
    'البداري',
  ],
  'سوهاج': [
    'سوهاج',
    'سوهاج الجديدة',
    'طهطا',
    'جرجا',
    'أخميم',
    'المراغة',
    'البلينا',
    'دار السلام',
    'جهينة',
    'ساقلتة',
    'العسيرات',
  ],
  'قنا': [
    'قنا',
    'قنا الجديدة',
    'نجع حمادي',
    'قوص',
    'دشنا',
    'أبو تشت',
    'نقادة',
    'الوقف',
    'فرشوط',
  ],
  'الأقصر': [
    'الأقصر',
    'إسنا',
    'أرمنت',
    'الطود',
    'الزينية',
    'القرنة',
  ],
  'أسوان': [
    'أسوان',
    'أسوان الجديدة',
    'كوم أمبو',
    'إدفو',
    'دراو',
    'نصر النوبة',
  ],
  'البحر الأحمر': [
    'الغردقة',
    'الغردقة الجديدة',
    'سفاجا',
    'القصير',
    'مرسى علم',
    'رأس غارب',
    'شلاتين',
    'حلايب',
  ],
  'مطروح': [
    'مرسى مطروح',
    'الحمام',
    'العلمين',
    'الضبعة',
    'سيدي براني',
    'السلوم',
    'سيوة',
  ],
  'الوادي الجديد': [
    'الخارجة',
    'الداخلة',
    'الفرافرة',
    'باريس',
    'بلاط',
  ],
  'شمال سيناء': [
    'العريش',
    'الشيخ زويد',
    'رفح',
    'بئر العبد',
    'الحسنة',
    'نخل',
  ],
  'جنوب سيناء': [
    'شرم الشيخ',
    'الطور',
    'دهب',
    'نويبع',
    'طابا',
    'سانت كاترين',
    'رأس سدر',
    'أبو رديس',
    'أبو زنيمة',
  ],
};

const Map<String, List<String>> _governorateDistricts = {
  'القاهرة': [
    'مدينة نصر',
    'مصر الجديدة',
    'وسط البلد',
    'الأزبكية',
    'الموسكي',
    'عين شمس',
  ],
  'الجيزة': [
    'الدقي',
    'المهندسين',
    'العجوزة',
    'إمبابة',
    'بولاق الدكرور',
  ],
  'الإسكندرية': [
    'محطة الرمل',
    'الإبراهيمية',
    'محرم بك',
    'كفر عبده',
    'سيدي بشر',
    'سموحة',
    'ميامي',
    'المنتزه',
  ],
  'القليوبية': [
    'وسط شبرا الخيمة',
    'وسط بنها',
  ],
  'الدقهلية': [
    'وسط المنصورة',
  ],
  'الشرقية': [
    'وسط الزقازيق',
  ],
  'الغربية': [
    'وسط طنطا',
    'وسط المحلة الكبرى',
  ],
  'المنوفية': [
    'وسط شبين الكوم',
    'وسط السادات',
  ],
  'كفر الشيخ': [
    'وسط كفر الشيخ',
    'وسط دسوق',
  ],
  'البحيرة': [
    'وسط دمنهور',
    'وسط كفر الدوار',
  ],
  'دمياط': [
    'وسط دمياط',
    'وسط دمياط الجديدة',
  ],
  'بورسعيد': [
    'حي الشرق',
    'حي العرب',
    'حي الضواحي',
    'حي الزهور',
    'حي المناخ',
    'حي الجنوب',
    'حي الغرب',
  ],
  'الإسماعيلية': [
    'وسط الإسماعيلية',
    'المناطق الصناعية والسياحية',
  ],
  'السويس': [
    'حي الأربعين',
    'حي الجناين',
    'حي فيصل',
    'حي السويس',
  ],
  'الفيوم': [
    'وسط الفيوم',
    'بحيرة قارون والمناطق القريبة',
  ],
  'بني سويف': [
    'وسط بني سويف',
    'المنطقة الصناعية',
  ],
  'المنيا': [
    'وسط المنيا',
    'وسط ملوي',
  ],
  'أسيوط': [
    'وسط أسيوط',
    'وسط ديروط',
  ],
  'سوهاج': [
    'وسط سوهاج',
  ],
  'قنا': [
    'وسط قنا',
  ],
  'الأقصر': [
    'وسط الأقصر',
    'طريق الكباش',
  ],
  'أسوان': [
    'وسط أسوان',
    'الكورنيش النيل',
  ],
  'البحر الأحمر': [
    'وسط الغردقة',
    'سهل حشيش',
  ],
  'مطروح': [
    'وسط مرسى مطروح',
    'سهلية',
  ],
  'الوادي الجديد': [
    'وسط الخارجة',
    'واحة باريس',
  ],
  'شمال سيناء': [
    'وسط العريش',
  ],
  'جنوب سيناء': [
    'خليج نعمة',
    'السوق القديم',
  ],
};

class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  final registerController = getIt<RegisterController>();
  final loginController = getIt<LoginController>();
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

  String? _selectedGovernorate;
  String? _selectedCity;
  String? _selectedDistrict;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool isRegistering = false;

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _registerCompany() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      _toast("يرجى ملء جميع الحقول المطلوبة");
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

    final result = await registerController.registerUser(company, _imageFile);

    if (!mounted) return; // Stop if user popped the page

    if (result.success) {
      final loginResult = await loginController.login(
        _emailController.text,
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
            "تسجيل شركة/متجر",
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
                    Icons.business,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'إنشاء حساب الشركة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : null,
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
                        // Business Type Selection
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
                                    'شركة',
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
                                    'متجر',
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

                        // Business Info
                        _buildSectionLabel('معلومات الشركة *'),
                        const SizedBox(height: 10),
                        _buildTextField(
                          _nameController,
                          "اسم الشركة/المؤسسة *",
                          Icons.business,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _ownerController,
                          "اسم المالك *",
                          Icons.person,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _businessController,
                          "اسم التخصص *",
                          Icons.work,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),

                        // Contact Info
                        _buildSectionLabel('معلومات الاتصال'),
                        const SizedBox(height: 10),
                        _buildTextField(
                          _emailController,
                          "البريد الإلكتروني *",
                          Icons.email,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _mobileController,
                          "رقم الجوال *",
                          Icons.phone,
                          keyboardType: TextInputType.phone,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextFieldMultiline(
                          _bioController,
                          "نبذة عن الشركة",
                          Icons.description,
                          lines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _referralController,
                          "كيف عرفت هذا التطبيق؟",
                          Icons.share,
                        ),
                        const SizedBox(height: 20),

                        // Location
                        _buildSectionLabel('الموقع الجغرافي'),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedGovernorate,
                          decoration: InputDecoration(
                            labelText: "المحافظة",
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: Color(0xFF13A9F6),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF13A9F6),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          items: _governorateCities.keys
                              .map(
                                (gov) => DropdownMenuItem<String>(
                                  value: gov,
                                  child: Text(gov),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGovernorate = value;
                              _selectedCity = null;
                              _selectedDistrict = null;
                              _governorateController.text = value ?? '';
                              _cityController.clear();
                              _districtController.clear();
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            labelText: "المدينة",
                            prefixIcon: const Icon(
                              Icons.location_city,
                              color: Color(0xFF13A9F6),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF13A9F6),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          items: (_selectedGovernorate == null
                                  ? <String>[]
                                  : _governorateCities[_selectedGovernorate] ??
                                      <String>[])
                              .map(
                                (city) => DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                          onChanged: _selectedGovernorate == null
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedCity = value;
                                    _selectedDistrict = null;
                                    _cityController.text = value ?? '';
                                    _districtController.clear();
                                  });
                                },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedDistrict,
                          decoration: InputDecoration(
                            labelText: "الحي",
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF13A9F6),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF13A9F6),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          items: (_selectedGovernorate == null
                                  ? <String>[]
                                  : _governorateDistricts[_selectedGovernorate] ??
                                      <String>[])
                              .map(
                                (district) => DropdownMenuItem<String>(
                                  value: district,
                                  child: Text(district),
                                ),
                              )
                              .toList(),
                          onChanged: _selectedGovernorate == null
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedDistrict = value;
                                    _districtController.text = value ?? '';
                                  });
                                },
                        ),
                        const SizedBox(height: 20),

                        // Passwords
                        _buildSectionLabel('كلمة المرور *'),
                        const SizedBox(height: 10),
                        _buildPasswordField(
                          _passwordController,
                          "كلمة المرور *",
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
                          "تأكيد كلمة المرور *",
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
                            onPressed: _registerCompany,
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
