import 'package:abokamall/controllers/ProfileController.dart';
import 'package:abokamall/controllers/SearchController.dart';
import 'package:abokamall/helpers/NetworkStatus.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/enums.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:abokamall/screens/worker_details_screen.dart';
import 'package:abokamall/services/UserListCache.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String search = '';
  Map<ProviderType, List<ServiceProvider>> cachedProviders = {};
  List<ServiceProvider> featuredProviders = [];
  int tabIndex = 0;
  late final searchcontroller searchController;
  late final UserListCacheService userListCacheService;
  bool isLoading = false;
  bool hasInternet = true;
  late final ProfileController profileController;

  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

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
    userListCacheService = getIt<UserListCacheService>();

    searchController = getIt<searchcontroller>();
    _connectivity = Connectivity();

    // Listen for connectivity changes
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen(_onConnectivityChanged);
    profileController = getIt<ProfileController>();
    // Load all provider types initially
    _loadProfile();
    _preloadAllProviders();
  }

  Future<void> _loadProfile() async {
    await profileController.fetchProfile();
  }

  Future<void> _preloadAllProviders() async {
    setState(() => isLoading = true);

    for (var type in providerTypes) {
      // Load from cache first
      final cached = userListCacheService.loadCachedUsers(
        type.name.toLowerCase(),
      );

      // If cache is expired and no internet, show message
      if (cached.isEmpty &&
          userListCacheService.isCacheExpired(type.name.toLowerCase()) &&
          !hasInternet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'انتهت صلاحية البيانات المخزنة مؤقتًا. يرجى الاتصال بالإنترنت.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Try fetching from server if internet is available
      if (hasInternet) {
        try {
          final providers = await searchController.searchWorkers(
            serverActionError: ServerActionError.unknown,
            context: context,
            providerType: type,
            basedOnPoints: true,
          );
          cachedProviders[type] = providers;

          // Cache the latest results
          await userListCacheService.cacheUsers(type.toString(), providers);
        } catch (_) {
          // Keep old cache if fetch fails
          cachedProviders[type] = cached.isNotEmpty ? cached : [];
        }
      } else {
        // No internet, use cached data
        cachedProviders[type] = cached;
      }
    }

    setState(() {
      featuredProviders = cachedProviders[providerTypes[tabIndex]] ?? [];
      isLoading = false;
    });
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final connected = result != ConnectivityResult.none;
    if (connected && !hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الاتصال بالإنترنت'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      _preloadAllProviders();
    }
    setState(() => hasInternet = connected);
  }

  Future<void> _loadFeaturedProviders(ProviderType type) async {
    setState(() {
      featuredProviders = cachedProviders[type] ?? [];
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'الصفحة الرئيسية',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        onRefresh: hasInternet
            ? () async => await _preloadAllProviders()
            : () async {},
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
                  child: const Icon(
                    Icons.home_outlined,
                    color: primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أهلاً بك!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'اكتشف مقدمي الخدمات المتاحين',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search & categories
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasInternet) ...[
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث عن خدمة...',
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          prefixIcon: const Icon(Icons.search, color: primary),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
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
                              color: primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (v) => setState(() => search = v),
                        onTap: () => Navigator.pushNamed(context, '/filters'),
                      ),

                      const SizedBox(height: 14),
                    ],
                    SizedBox(
                      height: 42,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        itemBuilder: (ctx, i) => GestureDetector(
                          onTap: () {
                            setState(() => tabIndex = i);
                            _loadFeaturedProviders(providerTypes[i]);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: tabIndex == i
                                  ? primary
                                  : const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(20),
                              border: tabIndex != i
                                  ? Border.all(
                                      color: const Color(0xFFE0E0E0),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              tabs[i],
                              style: TextStyle(
                                color: tabIndex == i
                                    ? Colors.white
                                    : Colors.black87,
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

            // Featured providers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'مقدمو الخدمة المميزون',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 12,
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

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
                  itemCount: featuredProviders.length,
                  itemBuilder: (ctx, i) {
                    final provider = featuredProviders[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkerProfilePage(provider: provider),
                        ),
                      ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pushNamed(context, '/payment'),
                child: const Text(
                  'الدفع',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pushNamed(context, '/payment'),
                child: const Text(
                  'خدمة العملاء',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
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
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: SizedBox(
                width: 80,
                height: 80,
                child: ClipOval(
                  child:
                      provider.imageUrl != null && provider.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: provider.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF5F7FA),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            return provider.isCompany
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.orange.withOpacity(0.15),
                                    ),
                                    child: Icon(
                                      Icons.business,
                                      color: Colors.orange,
                                      size: 24,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey[200],
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.blue[600],
                                      size: 28,
                                    ),
                                  );
                          },
                        )
                      : provider.isCompany
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.withOpacity(0.15),
                          ),
                          child: Icon(
                            Icons.business,
                            color: Colors.orange,
                            size: 24,
                          ),
                        )
                      : CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            color: Colors.blue[600],
                            size: 28,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.skill,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
