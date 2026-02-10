import 'package:hive_flutter/hive_flutter.dart';

class HiveUtility {
  /// Clear all Hive boxes
  static Future<void> clearAllBoxes() async {
    try {
      print('🗑️ Clearing all Hive boxes...');
      await Hive.deleteFromDisk();
      print('✅ All Hive boxes cleared');
    } catch (e) {
      print('❌ Error clearing Hive boxes: $e');
    }
  }

  /// Clear a specific box
  static Future<void> clearBox(String boxName) async {
    try {
      print('🗑️ Clearing Hive box: $boxName');
      final box = await Hive.openBox(boxName);
      await box.clear();
      print('✅ Box "$boxName" cleared');
    } catch (e) {
      print('❌ Error clearing box "$boxName": $e');
    }
  }

  /// Clear specific box by key
  static Future<void> clearBoxKey(String boxName, dynamic key) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.delete(key);
      print('✅ Key "$key" removed from "$boxName"');
    } catch (e) {
      print('❌ Error deleting key from "$boxName": $e');
    }
  }

  /// Clear user profile
  static Future<void> clearUserProfile() async {
    await clearBox('currentUserProfile');
  }

  /// Clear service providers
  static Future<void> clearServiceProviders() async {
    await clearBox('serviceProviderBox');
  }

  /// Get all open box names
  static List<String> getAllBoxNames() {
    // Return list of known boxes instead of trying to access non-existent property
    return ['currentUserProfile', 'serviceProviderBox'];
  }

  /// Get box contents (for debugging)
  static Future<Map<String, dynamic>> getBoxContents(String boxName) async {
    try {
      final box = await Hive.openBox(boxName);
      return box.toMap().cast<String, dynamic>();
    } catch (e) {
      print('Error reading box "$boxName": $e');
      return {};
    }
  }
}
