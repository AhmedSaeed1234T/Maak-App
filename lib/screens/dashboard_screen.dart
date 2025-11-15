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
    print(
      'Is SearchController registered? ${getIt.isRegistered<SearchController>()}',
    );

    super.initState();
    searchController = getIt<searchcontroller>();
    _loadFeaturedProviders(providerTypes[0], true);
  }

  Future<void> _loadFeaturedProviders(
    ProviderType type,
    bool basedOnPoints,
  ) async {
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
    );

    setState(() {
      featuredProviders = providers;
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
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن عامل، مهندس، شركة...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => search = v),
              onTap: () => Navigator.pushNamed(context, '/filters'),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () {
                    setState(() => tabIndex = i);
                    _loadFeaturedProviders(providerTypes[i], true);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: tabIndex == i
                          ? const Color(0xFF13A9F6)
                          : const Color(0xFFE8F0F8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        color: tabIndex == i ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "مقدمو الخدمة",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
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
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              provider.imageUrl != null &&
                                  provider.imageUrl!.isNotEmpty
                              ? NetworkImage(provider.imageUrl!)
                              : null,
                          child:
                              provider.imageUrl == null ||
                                  provider.imageUrl!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color(0xFF13A9F6),
                                )
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          provider.name ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          provider.skill,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 20),
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
