import 'package:abokamall/models/SearchResultDto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserListCacheService {
  static const String boxName = 'serviceProviderBox';
  static const int cacheTTLInDays = 2;

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

  /// Load cached users for a given type
  List<ServiceProvider> loadCachedUsers(String providerType) {
    final cachedData =
        _box.get(providerType, defaultValue: <dynamic>[]) as List;
    final now = DateTime.now();

    return cachedData
        .map((json) {
          // force type-safe conversion
          final safeJson = Map<String, dynamic>.from(json as Map);
          return ServiceProvider.fromJson(safeJson);
        })
        .where((u) => now.difference(u.cachedAt).inDays <= cacheTTLInDays)
        .toList();
  }

  /// Check if cache is valid for a type
  bool hasValidCache(String providerType) =>
      loadCachedUsers(providerType).isNotEmpty;

  /// Clear cache for a type
  Future<void> clearCache(String providerType) async =>
      await _box.delete(providerType);

  /// Clear all cache
  Future<void> clearAllCache() async => await _box.clear();
}
