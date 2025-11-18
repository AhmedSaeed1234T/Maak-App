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
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6FAFF),
      body: RefreshIndicator(
        onRefresh: () => _loadFeaturedProviders(providerTypes[tabIndex], true),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          children: [
            // Search and categories card (visual only)
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن عامل، مهندس، شركة...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF13A9F6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => setState(() => search = v),
                      onTap: () => Navigator.pushNamed(context, '/filters'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        itemBuilder: (ctx, i) => GestureDetector(
                          onTap: () {
                            setState(() {
                              tabIndex = i;
                            });
                            _loadFeaturedProviders(providerTypes[i], true);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: tabIndex == i
                                  ? const Color(0xFF13A9F6)
                                  : const Color(0xFFF3F7FB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tabs[i],
                              style: TextStyle(
                                color: tabIndex == i ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
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

            const SizedBox(height: 10),
            const Text(
              "مقدمو الخدمة",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Loading effect
            if (isLoading)
              const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredProviders.length >= 10
                      ? 10
                      : featuredProviders.length,
                  itemBuilder: (ctx, i) {
                    final provider = featuredProviders[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkerProfilePage(provider: provider),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                shape: const CircleBorder(),
                                elevation: 6,
                                color: Colors.white,
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Colors.white,
                                  backgroundImage: provider.imageUrl != null &&
                                          provider.imageUrl!.isNotEmpty
                                      ? NetworkImage(provider.imageUrl!)
                                      : null,
                                  child: provider.imageUrl == null || provider.imageUrl!.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          size: 36,
                                          color: Color(0xFF13A9F6),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                provider.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                provider.skill,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13A9F6),
                ),
                child: const Text('الدفع'),
                onPressed: () => Navigator.pushNamed(context, '/payment'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF13A9F6),
                ),
                child: const Text('خدمة العملاء'),
                onPressed: () => Navigator.pushNamed(context, '/payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
