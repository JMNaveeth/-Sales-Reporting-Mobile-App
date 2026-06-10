import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/app_exceptions.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiService: ref.watch(apiServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

class AuthRepository {
  const AuthRepository({
    required this.apiService,
    required this.storageService,
  });

  final ApiService apiService;
  final StorageService storageService;

  /// Logs the user in. Persists the token and user locally.
  /// Throws [AppException] on failure.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await apiService.login(email: email, password: password);

    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const AppException('No auth token received from server.');
    }

    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw const AppException('No user data received from server.');
    }

    final user = UserModel.fromJson({...userJson, 'token': token});

    // Persist both securely and in prefs
    await Future.wait([
      storageService.saveAuthToken(token),
      storageService.saveUser(user),
    ]);

    return user;
  }

  /// Logs the user out. Clears local storage.
  Future<void> logout() async {
    // Best-effort server-side logout; clear local storage regardless
    try {
      await apiService.logout();
    } catch (_) {}
    await storageService.clearAll();
  }

  /// Returns the persisted user if a valid token exists, otherwise null.
  Future<UserModel?> getStoredUser() async {
    final token = await storageService.getAuthToken();
    if (token == null || token.isEmpty) return null;
    return storageService.getUser();
  }

  Future<bool> isLoggedIn() async {
    final token = await storageService.getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
