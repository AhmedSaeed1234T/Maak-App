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

  List<ServiceProvider> loadCachedUsers(String providerType) {
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
      loadCachedUsers(providerType).isNotEmpty;
}
