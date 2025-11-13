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
  String? location = '';
  String? typeOfService;
  final TextEditingController locationController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();

  late Searchcontroller searchController;
  @override
  void initState() {
    searchController = getIt<Searchcontroller>();

    super.initState();
  }

  @override
  void dispose() {
    locationController.dispose();
    fullNameController.dispose();
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

    final providersList = await searchController.searchWorkers(
      fullNameController.text,
      specializationController.text,
      workerType,
      locationController.text,
      providerType,
    );

    if (providersList.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(providers: providersList),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' حدث خطأ أثناء البحث او لا يوجد مقدمون لهذه الخدمة'),
        ),
      );
    }
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
                    const Text(
                      "الاسم الكامل",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'ابحث بالاسم الكامل...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

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
                    const Text(
                      'الموقع',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        hintText: 'مثال: القاهرة، مصر',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                ),
              ),
            ),
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
                          locationController.clear();
                          fullNameController.clear();
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
                        backgroundColor: Color(0xFF13A9F6),
                      ),
                      onPressed: _applyFilters, // triggers the search
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
