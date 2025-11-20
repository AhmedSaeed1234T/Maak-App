import 'package:abokamall/controllers/SearchController.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/screens/search_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/enums.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}
class _FiltersScreenState extends State<FiltersScreen> {
  String? selectedProfession;
  String? typeOfService;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController governorateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  late searchcontroller searchController;
  @override
  void initState() {
    searchController = getIt<searchcontroller>();
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
        title: const Text('خيارات البحث', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                          child: const Icon(Icons.filter_list, color: primary, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'البحث المتقدم',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              Text(
                                'قم بتصفية النتائج حسب احتياجاتك',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                            _buildTextField(firstNameController, 'ابحث بالاسم الأول...', Icons.person),
                            const SizedBox(height: 16),

                            // Last Name
                            if (selectedProfession != 'شركة' &&
                                selectedProfession != 'متجر') ...[
                              _buildSectionLabel("اسم العائلة"),
                              const SizedBox(height: 8),
                              _buildTextField(lastNameController, 'ابحث باسم العائلة...', Icons.person_outline),
                              const SizedBox(height: 16),
                            ],

                            // Specialization
                            _buildSectionLabel("التخصص"),
                            const SizedBox(height: 8),
                            _buildTextField(specializationController, 'ابحث التخصص ...', Icons.work),
                            const SizedBox(height: 16),

                            // Profession Radio Buttons
                            _buildSectionLabel('التخصصات'),
                            const SizedBox(height: 10),
                            _buildProfessionRadioGroup(),
                            const SizedBox(height: 16),

                            // Location fields
                            _buildSectionLabel('المحافظة'),
                            const SizedBox(height: 8),
                            _buildTextField(governorateController, 'مثال: القاهرة', Icons.map),
                            const SizedBox(height: 16),

                            _buildSectionLabel('المدينة'),
                            const SizedBox(height: 8),
                            _buildTextField(cityController, 'مثال: مدينة نصر', Icons.location_city),
                            const SizedBox(height: 16),

                            _buildSectionLabel('الحي'),
                            const SizedBox(height: 8),
                            _buildTextField(districtController, 'مثال: التجمع الخامس', Icons.location_on_outlined),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('مسح الكل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _applyFilters,
                      child: const Text('تطبيق الفلاتر', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF13A9F6)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
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
            title: const Text('يومي', style: TextStyle(fontSize: 14, color: Colors.black87)),
            value: 'يومي',
            groupValue: typeOfService,
            activeColor: primary,
            onChanged: (val) => setState(() => typeOfService = val),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            dense: true,
          ),
          RadioListTile<String>(
            title: const Text('مقطوعية', style: TextStyle(fontSize: 14, color: Colors.black87)),
            value: 'مقطوعية',
            groupValue: typeOfService,
            activeColor: primary,
            onChanged: (val) => setState(() => typeOfService = val),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            dense: true,
          ),
        ],
      ),
    );
  }
}
