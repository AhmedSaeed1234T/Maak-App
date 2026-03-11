import 'package:abokamall/controllers/PresenceController.dart';
import 'package:abokamall/controllers/ProfileController.dart';
import 'package:abokamall/controllers/SearchController.dart';
import 'package:abokamall/controllers/NotificationController.dart';
import 'package:abokamall/helpers/ContextFunctions.dart';
import 'package:abokamall/helpers/NetworkStatus.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/enums.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:abokamall/screens/chat_screen.dart';
import 'package:abokamall/screens/chat_screen_debug.dart';
import 'package:abokamall/screens/debug_token_screen.dart';
import 'package:abokamall/screens/worker_details_screen.dart';
import 'package:abokamall/services/UserListCache.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:abokamall/helpers/FirebaseUtilities.dart';
import 'package:abokamall/widgets/dashboard/dashboard_header.dart';
import 'package:abokamall/widgets/dashboard/search_and_categories.dart';
import 'package:abokamall/widgets/dashboard/provider_card.dart';
import 'package:abokamall/widgets/dashboard/empty_state_widget.dart';

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
  Map<ProviderType, bool> sectionLoadingStates = {};
  bool isInitialLoad = true;
  bool hasInternet = true;
  bool hasValidCache = true;
  bool hasError = false;
  String errorMessage = '';
  late final ProfileController profileController;
  bool isExpired = false;
  String? expirationMessage;
  bool _isGracePassed = false; // ✅ NEW
  int _unreadCount = 0; // State for unread notifications
  DateTime? _lastNotificationCheck;

  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  final List<String> tabs = [
    'المقاولين',
    'الصنايعية',
    'المهندسين',
    'الشركات',
    'سوق العمالة',
    'عمال',
    'النحاتين', // Added Sculptors
  ];

  final List<ProviderType> providerTypes = [
    ProviderType.Contractors,
    ProviderType.Workers,
    ProviderType.Engineers,
    ProviderType.Companies,
    ProviderType.Marketplaces,
    ProviderType.Assistants,
    ProviderType.Sculptors, // Added Sculptors
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
        _checkUnreadNotifications(); // Initial check
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
      final senderImage = pendingData['senderImage'];

      if (senderId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              targetUserId: senderId,
              targetUserName: senderName,
              targetUserImage: senderImage,
            ),
          ),
        );
      }
    }
  }

  Future<void> _checkUnreadNotifications() async {
    if (!hasInternet) return;

    // Simple debounce/throttle
    if (_lastNotificationCheck != null &&
        DateTime.now().difference(_lastNotificationCheck!) <
            const Duration(seconds: 30)) {
      return;
    }

    try {
      final count = await getIt<NotificationController>().getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
          _lastNotificationCheck = DateTime.now();
        });
      }
    } catch (e) {
      debugPrint("Error checking unread notifications: $e");
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
          isInitialLoad = false;
          for (var type in providerTypes) {
            sectionLoadingStates[type] = false;
          }
          hasError = true;
          errorMessage = 'يجب الاتصال بالإنترنت لتحديث البيانات';
        });
        return;
      }
    }

    setState(() {
      isInitialLoad = true;
      hasError = false;
      errorMessage = '';
    });

    bool allCachesEmpty = true;

    // ⭐ STEP 1: Load ALL cached data immediately and display
    for (var type in providerTypes) {
      sectionLoadingStates[type] = true;
      final cached = await userListCacheService.loadCachedUsersAsync(
        type.name.toLowerCase(),
      );

      if (cached.isNotEmpty) {
        allCachesEmpty = false;
      }

      cachedProviders[type] = cached;
    }

    // Determine cache validity
    hasValidCache = !allCachesEmpty;
    if (!mounted) return;

    // ⭐ STEP 2: Update UI with cached data immediately
    setState(() {
      featuredProviders = cachedProviders[providerTypes[tabIndex]] ?? [];
      isInitialLoad = false;
    });

    // ⭐ STEP 3: Fetch fresh data for each section independently (in parallel)
    if (hasInternet) {
      for (var type in providerTypes) {
        _fetchSectionData(type); // Don't await - let them run in parallel
      }
    } else {
      // Mark all sections as loaded since we're offline
      if (!mounted) return;
      setState(() {
        for (var type in providerTypes) {
          sectionLoadingStates[type] = false;
        }
      });

      if (allCachesEmpty) {
        showSnackBar(
          'لا توجد بيانات متاحة. يرجى الاتصال بالإنترنت',
          Colors.red,
          duration: 4,
        );
      }
    }

    // ✅ Re-check status LOCALLY in case searchWorkers detected a 403 expiry
    await _checkSubscriptionStatus(onlyLocal: true);
  }

  Future<void> _fetchSectionData(ProviderType type) async {
    if (!mounted) return;

    try {
      final providers = await searchController.searchWorkers(
        serverActionError: ServerActionError.unknown,
        context: context,
        providerType: type,
        basedOnPoints: true,
      );

      if (!mounted) return;

      // Update immediately when this section loads
      setState(() {
        cachedProviders[type] = providers;
        sectionLoadingStates[type] = false;

        // If this is the currently viewed tab, update display
        if (providerTypes[tabIndex] == type) {
          featuredProviders = providers;
        }
      });

      // Cache the data
      await userListCacheService.cacheUsers(type.name.toLowerCase(), providers);
    } catch (e) {
      if (!mounted) return;

      // Mark as loaded even on error (fallback to cached data)
      setState(() {
        sectionLoadingStates[type] = false;

        // If cached data is empty and this is current tab, show error
        if (cachedProviders[type]?.isEmpty ?? true) {
          if (providerTypes[tabIndex] == type) {
            hasError = true;
            errorMessage = 'فشل تحميل البيانات. يرجى المحاولة مرة أخرى';
          }
        }
      });
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications');
                  // Refresh count after returning from notifications screen
                  _checkUnreadNotifications();
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(
                      4,
                    ), // Ensure circular shape even with 1 digit
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        _unreadCount > 9 ? '9+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1, // Fix vertical alignment
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
            DashboardHeader(hasInternet: hasInternet),
            const SizedBox(height: 20),

            // Search & categories
            SearchAndCategories(
              isExpired: isExpired,
              expirationMessage: expirationMessage,
              hasInternet: hasInternet,
              search: search,
              onSearchChanged: (v) => setState(() => search = v),
              onSearchTap: () => Navigator.pushNamed(context, '/filters'),
              tabs: tabs,
              tabIndex: tabIndex,
              providerTypes: providerTypes,
              onTabChanged: (i) {
                setState(() => tabIndex = i);
                loadFeaturedProviders(providerTypes[i]);
              },
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
            if (isInitialLoad)
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
              EmptyStateWidget(
                icon: Icons.cloud_off,
                title: 'لا يوجد اتصال بالإنترنت',
                message: 'يرجى الاتصال بالإنترنت لعرض مقدمي الخدمات',
                actionLabel: 'إعادة المحاولة',
                onAction: () => _preloadAllProviders(),
              )
            else if (hasError && featuredProviders.isEmpty)
              EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'حدث خطأ',
                message: errorMessage,
                actionLabel: 'إعادة المحاولة',
                onAction: () => _preloadAllProviders(),
              )
            else if (featuredProviders.isEmpty)
              EmptyStateWidget(
                icon: Icons.search_off,
                title: 'لا توجد نتائج',
                message: 'لم يتم العثور على مقدمي خدمات في هذه الفئة',
              )
            else
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredProviders.length,
                  itemBuilder: (ctx, i) {
                    final provider = featuredProviders[i];
                    return ProviderCard(
                      provider: provider,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkerProfilePage(provider: provider),
                        ),
                      ),
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
                        builder: (context) => SignalRTestPage(),
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
}
