import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({Key? key}) : super(key: key);

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  final Set<String> specializations = {};
  String? location = '';
  String? typeOfService;

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
              onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("التخصص", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextField(
                      decoration: const InputDecoration(hintText: 'ابحث بالتخصص...', border: OutlineInputBorder()),
                    ),
                    CheckboxListTile(
                      title: const Text('عامل'),
                      value: specializations.contains('عامل'),
                      onChanged: (val) => setState(() {val!? specializations.add('عامل') : specializations.remove('عامل');}),
                    ),
                    CheckboxListTile(
                      title: const Text('مقاول'),
                      value: specializations.contains('مقاول'),
                      onChanged: (val) => setState(() {val!? specializations.add('مقاول') : specializations.remove('مقاول');}),
                    ),
                    CheckboxListTile(
                      title: const Text('شركة'),
                      value: specializations.contains('شركة'),
                      onChanged: (val) => setState(() {val!? specializations.add('شركة') : specializations.remove('شركة');}),
                    ),
                    CheckboxListTile(
                      title: const Text('مهندس'),
                      value: specializations.contains('مهندس'),
                      onChanged: (val) => setState(() {val!? specializations.add('مهندس') : specializations.remove('مهندس');}),
                    ),
                    CheckboxListTile(
                      title: const Text('متجر'),
                      value: specializations.contains('متجر'),
                      onChanged: (val) => setState(() {val!? specializations.add('متجر') : specializations.remove('متجر');}),
                    ),
                    const SizedBox(height: 12),
                    const Text('الموقع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextField(
                      decoration: const InputDecoration(hintText: 'مثال: القاهرة، مصر', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder()),
                      onChanged: (val) => setState(() => location = val),
                    ),
                    const SizedBox(height: 14),
                    const Text('نوع الخدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          specializations.clear();
                          location = '';
                          typeOfService = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black54),
                      child: const Text('مسح الفلاتر'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6)),
                      onPressed: () {
                        // عند الضغط على تطبيق الفلاتر
                        Navigator.pop(context);
                      },
                      child: const Text('تطبيق الفلاتر'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
