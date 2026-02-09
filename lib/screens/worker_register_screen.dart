import 'dart:io';
import 'package:abokamall/controllers/LoginController.dart';
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

class WorkerRegisterScreen extends StatefulWidget {
  const WorkerRegisterScreen({super.key});
  @override
  State<WorkerRegisterScreen> createState() => _WorkerRegisterScreenState();
}

class _WorkerRegisterScreenState extends State<WorkerRegisterScreen> {
  final registerController = getIt<RegisterController>();
  final loginController = getIt<LoginController>();

  final _formKey = GlobalKey<FormState>();
  // Common styles
  final Color _primaryColor = const Color(0xFF13A9F6);
  // Image
  bool isRegistering = false;
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
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  final _referralController = TextEditingController(); // New referral code
  String salaryType = "daily"; // daily = 0, fixed = 1
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  String? _selectedGovernorate;
  String? _selectedCity;
  String? _selectedDistrict;
  // Pick image
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

  // Show simple toast
  void _toast(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Register worker
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
      providerType: "Worker",
      skill: _jobController.text.trim(),
      workerType: salaryType == "daily" ? 0 : 1,
      pay: double.tryParse(_salaryController.text.trim()) ?? 0,
      bio: _bioController.text.trim(),
      referralUserName: _referralController.text.trim(), // Added referral
    );

    final result = await registerController.registerUser(user, _imageFile);

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
    return WillPopScope(
      onWillPop: () async => !isRegistering,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تسجيل عامل"),
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
                // Profile Image Section with Shadow
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

                // Main Card with elevation
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
                        // Section header
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

                        // Name fields
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

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "البريد الالكتروني مطلوب"
                              : null,
                          decoration: _buildDecoration(
                            "البريد الالكتروني",
                            Icons.email,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phone
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

                        // Job
                        TextFormField(
                          controller: _jobController,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "المهنة مطلوبة"
                              : null,
                          decoration: _buildDecoration("المهنة", Icons.work),
                        ),
                        const SizedBox(height: 16),

                        // Salary Type Radio
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
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
                        const SizedBox(height: 16),

                        // Salary
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

                        // Bio
                        TextFormField(
                          controller: _bioController,
                          maxLines: 3,
                          decoration: _buildDecoration(
                            "نبذة عنك",
                            Icons.description,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Referral code
                        TextFormField(
                          controller: _referralController,
                          decoration: _buildDecoration(
                            "كيف عرفت هذا التطبيق؟",
                            Icons.share,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location
                        DropdownButtonFormField<String>(
                          value: _selectedGovernorate,
                          decoration: InputDecoration(
                            labelText: "المحافظة",
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: _primaryColor,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
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
                              borderSide: BorderSide(
                                color: _primaryColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.red, width: 2),
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
                              return "المحافظة مطلوبة";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            labelText: "المدينة",
                            prefixIcon: Icon(
                              Icons.location_city,
                              color: _primaryColor,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
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
                              borderSide: BorderSide(
                                color: _primaryColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.red, width: 2),
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
                              return "المدينة مطلوبة";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedDistrict,
                          decoration: InputDecoration(
                            labelText: "الحي",
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              color: _primaryColor,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
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
                              borderSide: BorderSide(
                                color: _primaryColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.red, width: 2),
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

                        // Password
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

                        // Confirm Password
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

                        // Submit button
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
