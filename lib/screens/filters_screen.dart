import 'package:abokamall/controllers/SearchController.dart';
import 'package:abokamall/helpers/ContextFunctions.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/screens/search_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/enums.dart';

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

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  String? selectedProfession;
  String? typeOfService;
  String? selectedGovernorate;
  String? selectedCity;
  String? selectedDistrict;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController governorateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  late searchcontroller searchController;
  late TokenService tokenService;

  @override
  void initState() {
    searchController = getIt<searchcontroller>();
    tokenService = getIt<TokenService>();

    checkSessionValidity(context, tokenService);
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    specializationController.dispose();
    governorateController.dispose();
    cityController.dispose();
    districtController.dispose();
    super.dispose();
  }

  int? _mapTypeOfServiceToWorkerType() {
    if (typeOfService == 'يومي') return 0;
    if (typeOfService == 'مقطوعية') return 1;
    return null;
  }

  ProviderType _mapProfessionToProviderType(String? profession) {
    switch (profession) {
      case 'مهندس':
        return ProviderType.Engineers;
      case 'مقاول':
        return ProviderType.Contractors;
      case 'شركة':
        return ProviderType.Companies;
      case 'متجر':
        return ProviderType.Marketplaces;
      case 'عامل':
      default:
        return ProviderType.Workers;
    }
  }

  Future<void> _applyFilters() async {
    if (selectedProfession == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار التخصص')));
      return;
    }
    final workerType = _mapTypeOfServiceToWorkerType();
    final providerType = _mapProfessionToProviderType(selectedProfession);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          specialization: specializationController.text,
          governorate: governorateController.text,
          city: cityController.text,
          district: districtController.text,
          workerType: workerType,
          providerType: providerType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          'خيارات البحث',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Icon
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'البحث المتقدم',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'قم بتصفية النتائج حسب احتياجاتك',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Main Card containing filter fields
                    Card(
                      elevation: 2,
                      shadowColor: primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First Name
                            _buildSectionLabel("الاسم الأول"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              firstNameController,
                              'ابحث بالاسم الأول...',
                              Icons.person,
                            ),
                            const SizedBox(height: 16),

                            // Last Name
                            if (selectedProfession != 'شركة' &&
                                selectedProfession != 'متجر') ...[
                              _buildSectionLabel("اسم العائلة"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                lastNameController,
                                'ابحث باسم العائلة...',
                                Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Specialization
                            _buildSectionLabel("التخصص"),
                            const SizedBox(height: 8),
                            _buildTextField(
                              specializationController,
                              'ابحث التخصص ...',
                              Icons.work,
                            ),
                            const SizedBox(height: 16),

                            // Profession Radio Buttons
                            _buildSectionLabel('التخصصات'),
                            const SizedBox(height: 10),
                            _buildProfessionRadioGroup(),
                            const SizedBox(height: 16),

                            // Location fields
                            _buildSectionLabel('المحافظة'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedGovernorate,
                              decoration: InputDecoration(
                                hintText: 'اختر المحافظة',
                                prefixIcon: const Icon(
                                  Icons.map,
                                  color: Color(0xFF13A9F6),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
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
                                  selectedGovernorate = value;
                                  selectedCity = null;
                                  selectedDistrict = null;
                                  governorateController.text = value ?? '';
                                  cityController.clear();
                                  districtController.clear();
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildSectionLabel('المدينة'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedCity,
                              decoration: InputDecoration(
                                hintText: selectedGovernorate == null
                                    ? 'اختر المحافظة أولاً'
                                    : 'اختر المدينة',
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
                              ),
                              items: (selectedGovernorate == null
                                      ? <String>[]
                                      : _governorateCities[
                                              selectedGovernorate] ??
                                          <String>[])
                                  .map(
                                    (city) => DropdownMenuItem<String>(
                                      value: city,
                                      child: Text(city),
                                    ),
                                  )
                                  .toList(),
                              onChanged: selectedGovernorate == null
                                  ? null
                                  : (value) {
                                      setState(() {
                                        selectedCity = value;
                                        selectedDistrict = null;
                                        cityController.text = value ?? '';
                                        districtController.clear();
                                      });
                                    },
                            ),
                            const SizedBox(height: 16),

                            _buildSectionLabel('الحي'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedDistrict,
                              decoration: InputDecoration(
                                hintText: selectedGovernorate == null
                                    ? 'اختر المحافظة أولاً'
                                    : 'اختر الحي',
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
                              ),
                              items: (selectedGovernorate == null
                                      ? <String>[]
                                      : _governorateDistricts[
                                              selectedGovernorate] ??
                                          <String>[])
                                  .map(
                                    (district) => DropdownMenuItem<String>(
                                      value: district,
                                      child: Text(district),
                                    ),
                                  )
                                  .toList(),
                              onChanged: selectedGovernorate == null
                                  ? null
                                  : (value) {
                                      setState(() {
                                        selectedDistrict = value;
                                        districtController.text = value ?? '';
                                      });
                                    },
                            ),
                            const SizedBox(height: 16),

                            // Worker Type (only for عامل)
                            if (selectedProfession == 'عامل') ...[
                              _buildSectionLabel('نوع الخدمة'),
                              const SizedBox(height: 10),
                              _buildServiceTypeRadioGroup(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedProfession = null;
                          selectedGovernorate = null;
                          selectedCity = null;
                          selectedDistrict = null;
                          firstNameController.clear();
                          lastNameController.clear();
                          specializationController.clear();
                          governorateController.clear();
                          cityController.clear();
                          districtController.clear();
                          typeOfService = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black54,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'مسح الكل',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _applyFilters,
                      child: const Text(
                        'تطبيق الفلاتر',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF13A9F6)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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

  Widget _buildProfessionRadioGroup() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRadioTile('عامل', 'عامل'),
          _buildRadioTile('مقاول', 'مقاول'),
          _buildRadioTile('شركة', 'شركة'),
          _buildRadioTile('مهندس', 'مهندس'),
          _buildRadioTile('متجر', 'متجر'),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String title, String value) {
    const primary = Color(0xFF13A9F6);
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      value: value,
      groupValue: selectedProfession,
      activeColor: primary,
      onChanged: (val) => setState(() => selectedProfession = val),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      dense: true,
    );
  }

  Widget _buildServiceTypeRadioGroup() {
    const primary = Color(0xFF13A9F6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text(
              'يومي',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            value: 'يومي',
            groupValue: typeOfService,
            activeColor: primary,
            onChanged: (val) => setState(() => typeOfService = val),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            selected: true,

            dense: true,
          ),
          RadioListTile<String>(
            title: const Text(
              'مقطوعية',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            value: 'مقطوعية',
            groupValue: typeOfService,
            activeColor: primary,
            onChanged: (val) => setState(() => typeOfService = val),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 2,
            ),
            selected: false,
            dense: true,
          ),
        ],
      ),
    );
  }
}
