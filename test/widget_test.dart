import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales_reporting_app/app.dart';
import 'package:sales_reporting_app/services/storage_service.dart';
import 'package:sales_reporting_app/services/api_service.dart';
import 'package:sales_reporting_app/models/user_model.dart';

class MockStorageService implements StorageService {
  @override
  Future<void> saveAuthToken(String token) async {}
  @override
  Future<String?> getAuthToken() async => null;
  @override
  Future<void> deleteAuthToken() async {}
  @override
  Future<void> saveUser(UserModel user) async {}
  @override
  Future<UserModel?> getUser() async => null;
  @override
  Future<void> deleteUser() async {}
  @override
  Future<void> setOnboardingComplete() async {}
  @override
  Future<bool> isOnboardingComplete() async => false;
  @override
  Future<void> saveSelectedPeriod(String period) async {}
  @override
  Future<String> getSelectedPeriod() async => 'monthly';
  @override
  Future<void> clearAll() async {}
}

class MockApiService implements ApiService {
  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    return {
      'token': 'mock_token',
      'user': {
        'id': 'u1',
        'name': 'Test User',
        'email': email,
        'role': 'admin',
      }
    };
  }
  @override
  Future<void> logout() async {}
  @override
  Future<Map<String, dynamic>> getCustomers({int page = 1, int limit = 20, String? search, String? status}) async => {};
  @override
  Future<Map<String, dynamic>> getCustomerById(String id) async => {};
  @override
  Future<Map<String, dynamic>> getReports({String period = 'monthly', int? year}) async => {};
  @override
  Future<Map<String, dynamic>> getDashboardStats() async => {};
}

void main() {
  testWidgets('App starts on login screen when unauthenticated', (WidgetTester tester) async {
    // Build our app under ProviderScope with mocks and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(MockStorageService()),
          apiServiceProvider.overrideWithValue(MockApiService()),
        ],
        child: const SalesReportingApp(),
      ),
    );

    // Let the GoRouter initialization and redirect complete
    await tester.pumpAndSettle();

    // Verify that the login screen is displayed.
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to your sales dashboard'), findsOneWidget);
  });
}
