import 'package:abokamall/models/SearchResultDto.dart';
import 'package:hive/hive.dart';

class UserListCacheService {
  static const String boxName = 'serviceProviderBox';
  static const int cacheTTLInDays = 2;

  late Box<ServiceProvider> _box;

  UserListCacheService() {
    _box = Hive.box<ServiceProvider>(boxName);
  }

  /// Cache a list of service providers
  Future<void> cacheUsers(List<ServiceProvider> users) async {
    await _box.clear(); // Clear old cache
    for (var user in users) {
      await _box.put(user.userName, user); // Use unique key (name or id)
    }
  }

  /// Load users from cache (valid only if TTL not expired)
  List<ServiceProvider> loadCachedUsers() {
    final now = DateTime.now();
    return _box.values
        .where((user) => now.difference(user.cachedAt).inDays <= cacheTTLInDays)
        .toList();
  }

  /// Check if we have valid cached users
  bool get hasValidCache => loadCachedUsers().isNotEmpty;

  /// Clear cache
  Future<void> clearCache() async => await _box.clear();
}
