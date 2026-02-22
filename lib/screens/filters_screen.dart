import 'package:abokamall/controllers/SearchController.dart';
import 'package:abokamall/helpers/ContextFunctions.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/screens/search_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:abokamall/helpers/enums.dart';
import '../widgets/location_fields.dart';

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
  final TextEditingController derivedSpecController =
      TextEditingController(); // Added
  final TextEditingController governorateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController marketplaceController =
      TextEditingController(); // Added
  String? _selectedGovernorate;
  String? _selectedCity;
  late searchcontroller searchController;
  late TokenService tokenService;
  // 'location' or 'marketplace'
  String _searchType = 'location';

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
    derivedSpecController.dispose(); // Added
    governorateController.dispose();
    cityController.dispose();
    districtController.dispose();
    marketplaceController.dispose(); // Added
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
      case 'محلات':
        return ProviderType.Marketplaces;
      case 'مساعد':
        return ProviderType.Assistants;
      case 'نحات':
        return ProviderType.Sculptors;
      case 'صنايعى':
      default:
        return ProviderType.Workers;
    }
  }

  Future<void> _applyFilters() async {
    if (selectedProfession == null) {
      CustomSnackBar.show(
        context,
        message: 'يرجى اختيار التخصص',
        type: SnackBarType.warning,
      );
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
          marketplace: marketplaceController.text, // Added
          derivedSpec: derivedSpecController.text, // Added
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
                                selectedProfession != 'محلات') ...[
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
                            if (selectedProfession != 'نحات') ...[
                              _buildSectionLabel("التخصص"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                specializationController,
                                'ابحث حسب المهنه ...',
                                Icons.work,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Derived Specialization (Hidden for Contractor, Company, Marketplace)
                            if (selectedProfession != 'مقاول' &&
                                selectedProfession != 'شركة' &&
                                selectedProfession != 'محلات' &&
                                selectedProfession != 'نحات') ...[
                              _buildSectionLabel("التخصص الفرعي"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                derivedSpecController,
                                'ابحث التخصص الفرعي ...',
                                Icons.build,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Profession Radio Buttons
                            _buildSectionLabel('التخصصات'),
                            const SizedBox(height: 10),
                            _buildProfessionRadioGroup(),
                            const SizedBox(height: 16),

                            // Search Type Toggle
                            _buildSectionLabel('نوع البحث'),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _searchType = 'location';
                                          marketplaceController.clear();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _searchType == 'location'
                                              ? primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'حسب الموقع',
                                            style: TextStyle(
                                              color: _searchType == 'location'
                                                  ? Colors.white
                                                  : Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _searchType = 'marketplace';
                                          _selectedGovernorate = null;
                                          _selectedCity = null;
                                          governorateController.clear();
                                          cityController.clear();
                                          districtController.clear();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _searchType == 'marketplace'
                                              ? primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'حسب سوق العماله  ',
                                            style: TextStyle(
                                              color:
                                                  _searchType == 'marketplace'
                                                  ? Colors.white
                                                  : Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Location Fields
                            if (_searchType == 'location') ...[
                              _buildSectionLabel('المحافظة'),
                              const SizedBox(height: 8),
                              GovernorateDropdownField(
                                controller: governorateController,
                                primaryColor: primary,
                                isRequired: false,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGovernorate = value;
                                    _selectedCity = null;
                                    cityController.clear();
                                    districtController.clear();
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildSectionLabel('المدينة'),
                              const SizedBox(height: 8),
                              CityDropdownField(
                                controller: cityController,
                                selectedGovernorate: _selectedGovernorate,
                                primaryColor: primary,
                                isRequired: false,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCity = value;
                                    districtController.clear();
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildSectionLabel('الحي'),
                              const SizedBox(height: 8),
                              DistrictDropdownField(
                                controller: districtController,
                                selectedGovernorate: _selectedGovernorate,
                                selectedCity: _selectedCity,
                                primaryColor: primary,
                                isRequired: false,
                              ),
                            ],

                            // Marketplace Field
                            if (_searchType == 'marketplace') ...[
                              _buildSectionLabel("اسم المحلات"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                marketplaceController,
                                'ابحث باسم المحلات ...',
                                Icons.store,
                              ),
                            ],
                            const SizedBox(height: 16),

                            // Worker Type (only for صنايعى or نحات)
                            if (selectedProfession == 'صنايعى' ||
                                selectedProfession == 'نحات') ...[
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
                          derivedSpecController.clear(); // Added
                          governorateController.clear();
                          cityController.clear();
                          districtController.clear();
                          marketplaceController.clear(); // Added
                          _selectedGovernorate = null;
                          _selectedCity = null;
                          typeOfService = null;
                          _searchType = 'location'; // Added
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
          _buildRadioTile('صنايعى', 'صنايعى'),
          _buildRadioTile('مقاول', 'مقاول'),
          _buildRadioTile('شركة', 'شركة'),
          _buildRadioTile('مهندس', 'مهندس'),
          _buildRadioTile('محلات', 'محلات'),
          _buildRadioTile('مساعد', 'مساعد'),
          _buildRadioTile('نحات', 'نحات'),
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
