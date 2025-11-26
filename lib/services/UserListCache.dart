import 'package:abokamall/models/SearchResultDto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserListCacheService {
  static const String boxName = 'serviceProviderBox';
  static const double cacheTTLInDays = 0.001;

  late final Box<List<dynamic>> _box;

  UserListCacheService._(this._box);

  /// Async factory to create the service and open the box if needed
  static Future<UserListCacheService> create() async {
    Box<List<dynamic>> box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box<List<dynamic>>(boxName);
    } else {
      box = await Hive.openBox<List<dynamic>>(boxName);
    }
    return UserListCacheService._(box);
  }

  /// Save a list of providers for a given type
  Future<void> cacheUsers(
    String providerType,
    List<ServiceProvider> users,
  ) async {
    final jsonList = users.map((u) => u.toJson()).toList();
    await _box.put(providerType, jsonList);
  }

  /// Load cached users for a given type (only valid entries)
  List<ServiceProvider> loadCachedUsers(String providerType) {
    final cachedData =
        _box.get(providerType, defaultValue: <dynamic>[]) as List;
    final now = DateTime.now();

    final validProviders = <ServiceProvider>[];
    final expiredProviders = <ServiceProvider>[];

    for (var json in cachedData) {
      final safeJson = Map<String, dynamic>.from(json as Map);
      final provider = ServiceProvider.fromJson(safeJson);
      if (now.difference(provider.cachedAt).inDays <= cacheTTLInDays) {
        validProviders.add(provider);
      } else {
        expiredProviders.add(provider);
      }
    }

    // Remove expired entries from Hive
    if (expiredProviders.isNotEmpty) {
      final jsonList = validProviders.map((u) => u.toJson()).toList();
      _box.put(providerType, jsonList);
    }

    return validProviders;
  }

  /// Check if cache exists and is still valid
  bool hasValidCache(String providerType) =>
      loadCachedUsers(providerType).isNotEmpty;

  /// Check if cache exists but is expired
  bool isCacheExpired(String providerType) {
    final cachedData =
        _box.get(providerType, defaultValue: <dynamic>[]) as List;
    if (cachedData.isEmpty) return false; // No cache at all

    final now = DateTime.now();
    // If any cached item is expired, we treat the cache as expired
    return cachedData.any((json) {
      final safeJson = Map<String, dynamic>.from(json as Map);
      final provider = ServiceProvider.fromJson(safeJson);
      return now.difference(provider.cachedAt).inDays > cacheTTLInDays;
    });
  }

  /// Clear cache for a type
  Future<void> clearCache(String providerType) async =>
      await _box.delete(providerType);

  /// Clear all cache
  Future<void> clearAllCache() async => await _box.clear();
}
