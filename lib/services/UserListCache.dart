import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserListCacheService {
  static const String boxName = 'serviceProviderBox';
  static const Duration cacheTTL = Duration(days: 2); // 5 min cache

  late final Box<List<dynamic>> _box;

  UserListCacheService._(this._box);

  static Future<UserListCacheService> create() async {
    Box<List<dynamic>> box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box<List<dynamic>>(boxName);
    } else {
      box = await Hive.openBox<List<dynamic>>(boxName);
    }
    return UserListCacheService._(box);
  }

  Future<void> cacheUsers(
    String providerType,
    List<ServiceProvider> users,
  ) async {
    final now = DateTime.now().toUtc();
    final usersWithCachedAt = users
        .map((u) => u.copyWith(cachedAt: now))
        .toList();
    final jsonList = usersWithCachedAt.map((u) => u.toJson()).toList();
    await _box.put(providerType, jsonList);
  }

  Future<List<ServiceProvider>> loadCachedUsersAsync(
    String providerType,
  ) async {
    // SECURITY: Use the centralized access check
    final tokenService = getIt<TokenService>();
    if (!(await tokenService.isDataAccessibleAsync())) {
      return [];
    }

    final cachedData =
        _box.get(providerType, defaultValue: <dynamic>[]) as List;
    final now = DateTime.now().toUtc();

    final valid = <ServiceProvider>[];
    for (var json in cachedData) {
      final provider = ServiceProvider.fromJson(
        Map<String, dynamic>.from(json),
      );

      // Strict TTL enforcement
      if (now.difference(provider.cachedAt) <= cacheTTL) {
        valid.add(provider);
      }
    }
    return valid;
  }

  /// ✅ Synchronous version for simple UI checks (still respects TTL)
  List<ServiceProvider> loadCachedUsersSync(String providerType) {
    final cachedData =
        _box.get(providerType, defaultValue: <dynamic>[]) as List;
    final now = DateTime.now().toUtc();

    final valid = <ServiceProvider>[];
    for (var json in cachedData) {
      final provider = ServiceProvider.fromJson(
        Map<String, dynamic>.from(json),
      );
      if (now.difference(provider.cachedAt) <= cacheTTL) {
        valid.add(provider);
      }
    }
    return valid;
  }

  bool hasValidCache(String providerType) =>
      loadCachedUsersSync(providerType).isNotEmpty;

  /// ✅ NEW: Clears all cached users from the box
  Future<void> clearAllCache() async {
    await _box.clear();
  }

  /// 🧪 DEBUG: Rewinds the 'cachedAt' timestamps for all entries
  /// Allows simulating aged data for testing the 2-day limit
  Future<void> debugRewindCacheTimestamps(Duration offset) async {
    for (var key in _box.keys) {
      final List<dynamic> cachedData = _box.get(key) as List;
      final updatedData = [];

      for (var json in cachedData) {
        final map = Map<String, dynamic>.from(json);
        final originalTime = DateTime.parse(map['cachedAt'] as String);
        final newTime = originalTime.subtract(offset);
        map['cachedAt'] = newTime.toUtc().toIso8601String();
        updatedData.add(map);
      }

      await _box.put(key, updatedData);
    }
  }
}
