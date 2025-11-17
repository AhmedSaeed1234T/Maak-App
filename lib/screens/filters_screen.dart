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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text('الفلاتر', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name
                    const Text(
                      "الاسم الأول",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        hintText: 'ابحث بالاسم الأول...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Last Name
                    if (selectedProfession != 'شركة' &&
                        selectedProfession != 'متجر') ...[
                      const Text(
                        "اسم العائلة",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          hintText: 'ابحث باسم العائلة...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Specialization
                    const Text(
                      "التخصص",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: specializationController,
                      decoration: const InputDecoration(
                        hintText: 'ابحث التخصص ...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Profession Radio Buttons
                    RadioListTile<String>(
                      title: const Text('عامل'),
                      value: 'عامل',
                      groupValue: selectedProfession,
                      onChanged: (val) =>
                          setState(() => selectedProfession = val),
                    ),
                    RadioListTile<String>(
                      title: const Text('مقاول'),
                      value: 'مقاول',
                      groupValue: selectedProfession,
                      onChanged: (val) =>
                          setState(() => selectedProfession = val),
                    ),
                    RadioListTile<String>(
                      title: const Text('شركة'),
                      value: 'شركة',
                      groupValue: selectedProfession,
                      onChanged: (val) =>
                          setState(() => selectedProfession = val),
                    ),
                    RadioListTile<String>(
                      title: const Text('مهندس'),
                      value: 'مهندس',
                      groupValue: selectedProfession,
                      onChanged: (val) =>
                          setState(() => selectedProfession = val),
                    ),
                    RadioListTile<String>(
                      title: const Text('متجر'),
                      value: 'متجر',
                      groupValue: selectedProfession,
                      onChanged: (val) =>
                          setState(() => selectedProfession = val),
                    ),

                    const SizedBox(height: 12),
                    // Location fields
                    const Text(
                      'المحافظة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: governorateController,
                      decoration: const InputDecoration(
                        hintText: 'مثال: القاهرة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'المدينة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        hintText: 'مثال: مدينة نصر',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'الحي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: districtController,
                      decoration: const InputDecoration(
                        hintText: 'مثال: التجمع الخامس',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Worker Type (only for عامل)
                    if (selectedProfession == 'عامل') ...[
                      const Text(
                        'نوع الخدمة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text('يومي'),
                        value: 'يومي',
                        groupValue: typeOfService,
                        onChanged: (val) => setState(() => typeOfService = val),
                      ),
                      RadioListTile<String>(
                        title: const Text('مقطوعية'),
                        value: 'مقطوعية',
                        groupValue: typeOfService,
                        onChanged: (val) => setState(() => typeOfService = val),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                      ),
                      child: const Text('مسح الفلاتر'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF13A9F6),
                      ),
                      onPressed: _applyFilters,
                      child: const Text('تطبيق الفلاتر'),
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
}
