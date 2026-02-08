import 'package:abokamall/controllers/SearchController.dart';
import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/enums.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:abokamall/screens/worker_details_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String search = '';
  List<ServiceProvider> featuredProviders = [];
  int tabIndex = 0;
  late final searchcontroller searchController;
  bool isLoading = false; 

  final List<String> tabs = [
    'المقاولين',
    'العمال',
    'المهندسين',
    'الشركات',
    'المتاجر',
  ];

  final List<ProviderType> providerTypes = [
    ProviderType.Contractors,
    ProviderType.Workers,
    ProviderType.Engineers,
    ProviderType.Companies,
    ProviderType.Marketplaces,
  ];

  @override
  void initState() {
    super.initState();
    searchController = getIt<searchcontroller>();
    _loadFeaturedProviders(providerTypes[0], true);
  }

  Future<void> _loadFeaturedProviders(
    ProviderType type,
    bool basedOnPoints,
  ) async {
    setState(() => isLoading = true); // show loader

    // simulate network delay if needed
    await Future.delayed(const Duration(milliseconds: 500));
    final providers = await searchController.searchWorkers(
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      type,
      basedOnPoints,
      1,
    );

    setState(() {
      featuredProviders = providers;
      isLoading = false; // hide loader
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('لوحة التحكم', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadFeaturedProviders(providerTypes[tabIndex], true),
        color: primary,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          children: [
            // Header Section
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(0.15),
                  ),
                  child: const Icon(Icons.home_outlined, color: primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('أهلاً بك!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('اكتشف مقدمي الخدمات المتاحين', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Search and categories card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن خدمة...',
                        filled: true,
                        fillColor: Color(0xFFF5F7FA),
                        prefixIcon: const Icon(Icons.search, color: primary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          borderSide: const BorderSide(color: primary, width: 2),
                        ),
                      ),
                      onChanged: (v) => setState(() => search = v),
                      onTap: () => Navigator.pushNamed(context, '/filters'),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 42,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        itemBuilder: (ctx, i) => GestureDetector(
                          onTap: () {
                            setState(() => tabIndex = i);
                            _loadFeaturedProviders(providerTypes[i], true);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: tabIndex == i ? primary : Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(20),
                              border: tabIndex != i ? Border.all(color: Color(0xFFE0E0E0), width: 1) : null,
                            ),
                            child: Text(
                              tabs[i],
                              style: TextStyle(
                                color: tabIndex == i ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مقدمو الخدمة المميزون', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('عرض الكل', style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),

            // Loading effect
            if (isLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: primary)),
              )
            else
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredProviders.length >= 10 ? 10 : featuredProviders.length,
                  itemBuilder: (ctx, i) {
                    final provider = featuredProviders[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerProfilePage(provider: provider),
                          ),
                        );
                      },
                      child: _buildProviderCard(provider),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                ),
              ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pushNamed(context, '/payment'),
                child: const Text('الدفع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pushNamed(context, '/payment'),
                child: const Text('خدمة العملاء', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(ServiceProvider provider) {
    const primary = Color(0xFF13A9F6);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFF5F7FA),
                backgroundImage: provider.imageUrl != null && provider.imageUrl!.isNotEmpty
                    ? NetworkImage(provider.imageUrl!)
                    : null,
                child: provider.imageUrl == null || provider.imageUrl!.isEmpty
                    ? const Icon(Icons.person, size: 40, color: primary)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              provider.skill,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '⭐ 4.8',
                style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
