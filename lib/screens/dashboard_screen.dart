import 'package:abokamall/controllers/PresenceController.dart';
import 'package:abokamall/controllers/ProfileController.dart';
import 'package:abokamall/controllers/SearchController.dart';
import 'package:abokamall/helpers/ContextFunctions.dart';
import 'package:abokamall/helpers/NetworkStatus.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/enums.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:abokamall/screens/chat_screen.dart';
import 'package:abokamall/screens/debug_token_screen.dart';
import 'package:abokamall/screens/worker_details_screen.dart';
import 'package:abokamall/services/UserListCache.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:abokamall/helpers/FirebaseUtilities.dart';
import 'package:abokamall/screens/chat_screen.dart';

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
  late final TokenService tokenService;
  bool isLoading = false;
  bool hasInternet = true;
  bool hasValidCache = true;
  bool hasError = false;
  String errorMessage = '';
  late final ProfileController profileController;
  bool isExpired = false;
  String? expirationMessage;
  bool _isGracePassed = false; // ✅ NEW

  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  final List<String> tabs = [
    'المقاولين',
    'العمال',
    'المهندسين',
    'الشركات',
    'المتاجر',
    'المساعدين',
  ];

  final List<ProviderType> providerTypes = [
    ProviderType.Contractors,
    ProviderType.Workers,
    ProviderType.Engineers,
    ProviderType.Companies,
    ProviderType.Marketplaces,
    ProviderType.Assistants,
  ];

  @override
  void initState() {
    super.initState();

    userListCacheService = getIt<UserListCacheService>();
    searchController = getIt<searchcontroller>();
    profileController = getIt<ProfileController>();
    tokenService = getIt<TokenService>();
    getIt<PresenceController>().connect();

    _initData();

    if (mounted) {
      _connectivity = Connectivity();
      _checkInitialConnectivity();
      _connectivityStream = _connectivity.onConnectivityChanged;
      _connectivityStream.listen(onConnectivityChanged);

      // Check for pending notification from terminated state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkPendingNotification();
      });
    }
  }

  void _checkPendingNotification() {
    final pendingData = FirebaseUtilities.pendingNotificationData;
    if (pendingData != null) {
      debugPrint("🚀 Handling pending notification in Dashboard");
      FirebaseUtilities.pendingNotificationData = null; // Clear it

      final senderId = pendingData['senderId'];
      final senderName = pendingData['senderName'] ?? 'User';

      if (senderId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatScreen(targetUserId: senderId, targetUserName: senderName),
          ),
        );
      }
    }
  }

  Future<void> _initData() async {
    // Ensuring everything is correctly initialized
    await _checkSubscriptionStatus();
    await _preloadAllProviders();
  }

  Future<void> _checkInitialConnectivity() async {
    if (!mounted) return;
    final result = await _connectivity.checkConnectivity();
    final connected = result != ConnectivityResult.none;

    setState(() => hasInternet = connected);

    if (!connected) {
      showSnackBar(
        'لا يوجد اتصال بالإنترنت. سيتم عرض البيانات المخزنة',
        Colors.orange,
        duration: 3,
      );
    }

    await _preloadAllProviders();
  }

  Future<void> _checkSubscriptionStatus({bool onlyLocal = false}) async {
    // 1. Immediate local check for fast UI reaction
    final localExpired = await isCurrentUserExpired();
    String? localMessage;
    if (localExpired) {
      localMessage = await getFormattedSubscriptionMessage();
    }

    if (mounted) {
      setState(() {
        isExpired = localExpired;
        expirationMessage = localMessage;
      });
    }

    // 2. Proactively refetch profile if online (Skip if onlyLocal requested)
    if (hasInternet && !onlyLocal) {
      try {
        await profileController.fetchProfile(forceRefresh: true);
      } catch (e) {
        debugPrint('Dashboard: Error refreshing profile status: $e');
      }
    }

    final finalExpired = await isCurrentUserExpired();
    final gracePassed = await tokenService.mustCheckOnline();

    // ✅ NEW: Notify user if status changed
    if (mounted && isExpired != finalExpired) {
      if (finalExpired) {
        CustomSnackBar.show(
          context,
          message: 'لقد انتهي اشتراكك',
          type: SnackBarType.error,
          duration: 5,
        );
      } else {
        CustomSnackBar.show(
          context,
          message: 'تم تفعيل اشتراكك بنجاح!',
          type: SnackBarType.success,
          duration: 5,
        );
      }
    }

    String? finalMessage;
    if (finalExpired) {
      finalMessage = await getFormattedSubscriptionMessage();
    }

    if (mounted) {
      setState(() {
        isExpired = finalExpired;
        expirationMessage = finalMessage;
        _isGracePassed = gracePassed;
      });
    }
  }

  Future<void> _preloadAllProviders() async {
    if (!mounted) return;

    // ✅ 1. Update local UI state FIRST with latest known info (fast)
    await _checkSubscriptionStatus();

    // ⭐ 2. Prepare for network check ⭐
    // Clear "permanent failure" markers ONLY if online, to give the network a chance.
    if (hasInternet) {
      await tokenService.clearRefreshInvalidStatus();
      // Note: We don't forceClearExpiryFlag here anymore to avoid UI flickering.
      // _checkSubscriptionStatus already handles the network refresh.
    }

    // ⭐ Strict 2-day offline check ⭐
    // Only block the entire refresh if the HARD security limit is passed.
    if (await tokenService.mustCheckOnline() && !hasInternet) {
      final isSessionValid = await checkSessionValidity(context, tokenService);
      if (!isSessionValid) {
        if (!mounted) return;
        setState(() {
          featuredProviders = [];
          cachedProviders = {};
          isLoading = false;
          hasError = true;
          errorMessage = 'يجب الاتصال بالإنترنت لتحديث البيانات';
        });
        return;
      }
    }

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    bool hasFreshData = false;
    bool allCachesEmpty = true;

    for (var type in providerTypes) {
      final cached = await userListCacheService.loadCachedUsersAsync(
        type.name.toLowerCase(),
      );

      if (cached.isNotEmpty) {
        allCachesEmpty = false;
      }

      if (hasInternet) {
        try {
          final providers = await searchController.searchWorkers(
            serverActionError: ServerActionError.unknown,
            context: context,
            providerType: type,
            basedOnPoints: true,
          );

          cachedProviders[type] = providers;
          await userListCacheService.cacheUsers(
            type.name.toLowerCase(),
            providers,
          );
          hasFreshData = true;
        } catch (e) {
          // Fallback to cache on error
          cachedProviders[type] = cached;
          if (!mounted) return;

          if (cached.isEmpty) {
            setState(() {
              hasError = true;
              errorMessage = 'فشل تحميل البيانات. يرجى المحاولة مرة أخرى';
            });
          }
        }
      } else {
        cachedProviders[type] = cached;
      }
    }

    // Determine cache validity
    hasValidCache = !allCachesEmpty;
    if (!mounted) return;

    // ✅ NEW: Re-check status LOCALLY in case searchWorkers detected a 403 expiry
    await _checkSubscriptionStatus(onlyLocal: true);

    setState(() {
      featuredProviders = cachedProviders[providerTypes[tabIndex]] ?? [];
      isLoading = false;
    });

    // Show appropriate messages
    if (!hasInternet && allCachesEmpty) {
      showSnackBar(
        'لا توجد بيانات متاحة. يرجى الاتصال بالإنترنت',
        Colors.red,
        duration: 4,
      );
    } else if (!hasInternet && hasValidCache) {
      // Already shown message in _checkInitialConnectivity
    } else if (hasInternet && hasFreshData) {
      // Successfully loaded fresh data - no message needed
    }
  }

  Future<void> onConnectivityChanged(ConnectivityResult result) async {
    if (!mounted) return;

    final connected = result != ConnectivityResult.none;

    if (connected && !hasInternet) {
      // Reconnected
      setState(() => hasInternet = connected);

      showSnackBar(
        'تم الاتصال بالإنترنت. جاري تحديث البيانات...',
        Colors.green,
        duration: 2,
      );

      // ✅ Proactively reset local flags to allow recovery
      await tokenService.clearRefreshInvalidStatus();

      // ✅ Proactively refresh session/grace period status
      await _checkSubscriptionStatus();
      await _preloadAllProviders();
    } else if (!connected && hasInternet) {
      if (!mounted) return;

      // Disconnected - load cached data immediately
      setState(() => hasInternet = connected);

      // Load cached data for all provider types
      bool hasCachedData = false;
      for (var type in providerTypes) {
        final cached = await userListCacheService.loadCachedUsersAsync(
          type.name.toLowerCase(),
        );
        if (cached.isNotEmpty) {
          hasCachedData = true;
          cachedProviders[type] = cached;
        }
      }
      if (!mounted) return;

      // Update the displayed providers for current tab
      setState(() {
        featuredProviders = cachedProviders[providerTypes[tabIndex]] ?? [];
        hasValidCache = hasCachedData;
      });

      if (hasCachedData) {
        showSnackBar(
          'انقطع الاتصال بالإنترنت. سيتم عرض البيانات المخزنة',
          Colors.orange,
          duration: 3,
        );
      } else {
        showSnackBar(
          'انقطع الاتصال بالإنترنت ولا توجد بيانات مخزنة',
          Colors.red,
          duration: 3,
        );
      }
    } else {
      if (!mounted) return;

      setState(() => hasInternet = connected);
    }
  }

  void showSnackBar(String message, Color color, {int duration = 2}) {
    if (!mounted) return;

    SnackBarType type = SnackBarType.info;
    if (color == Colors.green) {
      type = SnackBarType.success;
    } else if (color == Colors.orange) {
      type = SnackBarType.warning;
    } else if (color == Colors.red) {
      type = SnackBarType.error;
    }

    CustomSnackBar.show(
      context,
      message: message,
      type: type,
      duration: duration,
    );
  }

  Future<void> loadFeaturedProviders(ProviderType type) async {
    if (!mounted) return;

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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text(
              'الصفحة الرئيسية',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            // Connection indicator
            if (!hasInternet)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 14, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      'غير متصل',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
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
            ? () async {
                await _preloadAllProviders();
              }
            : () async {
                showSnackBar(
                  'يرجى الاتصال بالإنترنت لتحديث البيانات',
                  Colors.orange,
                );
              },
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
                        hasInternet
                            ? 'اكتشف مقدمي الخدمات المتاحين'
                            : 'عرض البيانات المخزنة',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasInternet ? Colors.grey[600] : Colors.orange,
                        ),
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
                    if (isExpired) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B0000).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8B0000).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFF8B0000),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                expirationMessage ?? "لقد انتهي اشتراكك",
                                style: const TextStyle(
                                  color: Color(0xFF8B0000),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'Cairo',
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ] else if (hasInternet) ...[
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
                            loadFeaturedProviders(providerTypes[i]);
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
                if (!hasInternet && hasValidCache)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.offline_bolt,
                          size: 14,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'محفوظة',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Content area
            if (isLoading)
              const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primary),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل البيانات...',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else if (!hasInternet && !hasValidCache)
              buildEmptyState(
                icon: Icons.cloud_off,
                title: 'لا يوجد اتصال بالإنترنت',
                message: 'يرجى الاتصال بالإنترنت لعرض مقدمي الخدمات',
                actionLabel: 'إعادة المحاولة',
                onAction: () => _preloadAllProviders(),
              )
            else if (hasError && featuredProviders.isEmpty)
              buildEmptyState(
                icon: Icons.error_outline,
                title: 'حدث خطأ',
                message: errorMessage,
                actionLabel: 'إعادة المحاولة',
                onAction: () => _preloadAllProviders(),
              )
            else if (featuredProviders.isEmpty)
              buildEmptyState(
                icon: Icons.search_off,
                title: 'لا توجد نتائج',
                message: 'لم يتم العثور على مقدمي خدمات في هذه الفئة',
                actionLabel: null,
                onAction: null,
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
                      child: buildProviderCard(provider),
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
                onPressed: (_isGracePassed && !hasInternet)
                    ? () {
                        showSnackBar(
                          'يجب الاتصال بالإنترنت لتحديث حالة الدفع',
                          Colors.orange,
                          duration: 4,
                        );
                      }
                    : () async {
                        try {
                          UserProfile? userData = await profileController
                              .fetchProfile();
                          if (userData == null) {
                            showSnackBar(
                              'يجب الاتصال بالإنترنت لتحديث بيانات الاشتراك',
                              Colors.orange,
                              duration: 4,
                            );
                            return;
                          }
                          debugPrint(userData.subscription!.endDate.toString());
                          Navigator.of(context).pushNamed(
                            '/subscription_status',
                            arguments: userData,
                          );
                        } catch (e) {
                          CustomSnackBar.show(
                            context,
                            message:
                                'حدث خطأ أثناء جلب حالة الاشتراك: ${e.toString()}',
                            type: SnackBarType.error,
                          );
                          debugPrint(e.toString());
                        }
                      },
                child: Text(
                  'الدفع',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: (_isGracePassed && !hasInternet)
                        ? Colors.white70
                        : Colors.white,
                  ),
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
                onPressed: () {
                  if (kDebugMode) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OfflineModeTestingPanel(),
                      ),
                    );
                  } else {
                    Navigator.of(context).pushNamed('/payment');
                  }
                },
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

  Widget buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    const primary = Color(0xFF13A9F6);
    return Container(
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: primary),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildProviderCard(ServiceProvider provider) {
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
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipOval(
                      child:
                          provider.imageUrl != null &&
                              provider.imageUrl!.isNotEmpty
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
                                          color: Colors.orange.withOpacity(
                                            0.15,
                                          ),
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
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: getIt<PresenceController>().onlineUsers,
                    builder: (context, onlineUsers, _) {
                      final isOnline = getIt<PresenceController>().isUserOnline(
                        provider.userId,
                      );
                      return Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
