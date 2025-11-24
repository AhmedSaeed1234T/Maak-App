import 'package:abokamall/models/UserProfile.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileCacheService {
  static const String boxName = 'currentUserProfile';
  static const String key = 'profile';
  static const int cacheTTLInDays = 2;

  late Box<UserProfile> _box;

  ProfileCacheService() {
    _box = Hive.box<UserProfile>(boxName);
  }

  /// Save profile to cache
  Future<void> cacheProfile(UserProfile profile) async {
    await _box.put(key, profile);
  }

  /// Load profile from cache
  UserProfile? loadCachedProfile() {
    final cachedProfile = _box.get(key);
    if (cachedProfile == null) return null;

    final now = DateTime.now();
    final age = now.difference(cachedProfile.cachedAt).inDays;

    if (age > cacheTTLInDays) {
      // Cache expired
      return null;
    }

    return cachedProfile;
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _box.delete(key);
  }

  /// Check if profile is available offline
  bool get hasValidCache => loadCachedProfile() != null;
}
