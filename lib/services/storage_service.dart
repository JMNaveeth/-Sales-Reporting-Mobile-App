import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ── Auth Token (Secure) ──────────────────────────────────────────────────────

  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(
      key: StorageKeys.authToken,
      value: token,
    );
  }

  Future<String?> getAuthToken() async {
    return _secureStorage.read(key: StorageKeys.authToken);
  }

  Future<void> deleteAuthToken() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
  }

  // ── User Data (SharedPreferences — non-sensitive) ────────────────────────────

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.currentUser,
      jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(StorageKeys.currentUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.currentUser);
  }

  // ── App Preferences ──────────────────────────────────────────────────────────

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.onboardingDone, true);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.onboardingDone) ?? false;
  }

  Future<void> saveSelectedPeriod(String period) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.selectedPeriod, period);
  }

  Future<String> getSelectedPeriod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.selectedPeriod) ?? 'monthly';
  }

  // ── Clear All ────────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    // Keep non-auth preferences intact
    await prefs.remove(StorageKeys.currentUser);
  }
}

/// Storage key constants to avoid magic strings
class StorageKeys {
  static const authToken = 'auth_token';
  static const currentUser = 'current_user';
  static const onboardingDone = 'onboarding_done';
  static const selectedPeriod = 'selected_period';
}
