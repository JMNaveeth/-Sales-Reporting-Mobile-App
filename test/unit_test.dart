import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_reporting_app/services/api_service.dart';
import 'package:sales_reporting_app/services/storage_service.dart';
import 'package:sales_reporting_app/repositories/auth_repository.dart';
import 'package:sales_reporting_app/repositories/customer_repository.dart';
import 'package:sales_reporting_app/models/customer_model.dart';
import 'package:sales_reporting_app/models/user_model.dart';

// ── Mock Implementations ─────────────────────────────────────────────────────

class MockStorageService implements StorageService {
  String? _token;
  UserModel? _user;

  @override
  Future<void> saveAuthToken(String token) async => _token = token;

  @override
  Future<String?> getAuthToken() async => _token;

  @override
  Future<void> deleteAuthToken() async => _token = null;

  @override
  Future<void> saveUser(UserModel user) async => _user = user;

  @override
  Future<UserModel?> getUser() async => _user;

  @override
  Future<void> deleteUser() async => _user = null;

  @override
  Future<void> clearAll() async {
    _token = null;
    _user = null;
  }

  @override
  Future<bool> isOnboardingComplete() async => false;

  @override
  Future<void> setOnboardingComplete() async {}

  @override
  Future<void> saveSelectedPeriod(String period) async {}

  @override
  Future<String> getSelectedPeriod() async => 'monthly';
}

class MockApiService implements ApiService {
  bool shouldFailLogin = false;
  bool shouldFailCustomers = false;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (shouldFailLogin) {
      throw Exception('Invalid credentials');
    }
    return {
      'token': 'test_token_abc',
      'user': {
        'id': 'u1',
        'name': 'Test User',
        'email': email,
        'role': 'admin',
      },
    };
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    if (shouldFailCustomers) {
      throw Exception('Network error');
    }
    final customers = [
      {
        'id': 'c1',
        'name': 'Alice Smith',
        'email': 'alice@example.com',
        'phone': '+94 71 555 0001',
        'total_purchases': 1500.0,
        'last_purchase_date': '2024-05-01T00:00:00Z',
        'status': 'active',
      },
      {
        'id': 'c2',
        'name': 'Bob Jones',
        'email': 'bob@example.com',
        'phone': '+94 77 555 0002',
        'total_purchases': 2500.0,
        'last_purchase_date': '2024-04-15T00:00:00Z',
        'status': 'inactive',
      },
    ];

    final filtered = search != null && search.isNotEmpty
        ? customers
            .where((c) => (c['name'] as String)
                .toLowerCase()
                .contains(search.toLowerCase()))
            .toList()
        : customers;

    return {'customers': filtered, 'total': filtered.length};
  }

  @override
  Future<Map<String, dynamic>> getCustomerById(String id) async {
    return {
      'customer': {
        'id': id,
        'name': 'Test Customer',
        'email': 'test@example.com',
        'phone': '+94 75 555 9999',
        'total_purchases': 500.0,
        'last_purchase_date': '2024-01-01T00:00:00Z',
        'status': 'active',
      }
    };
  }

  @override
  Future<Map<String, dynamic>> getReports({
    String period = 'monthly',
    int? year,
  }) async {
    return {
      'report': {
        'id': 'r1',
        'title': 'Test Report',
        'period': period,
        'total_revenue': 50000.0,
        'total_orders': 100,
        'total_customers': 30,
        'growth_rate': 5.0,
        'generated_at': '2024-06-01T00:00:00Z',
        'monthly_sales': [],
        'top_products': [],
      }
    };
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    return {
      'total_revenue': 100000.0,
      'total_orders': 250,
      'total_customers': 75,
      'revenue_growth': 10.0,
      'orders_growth': 5.0,
      'customers_growth': 3.0,
      'recent_sales': [],
    };
  }
}

// ── Auth / Login Service Tests ────────────────────────────────────────────────

void main() {
  group('AuthRepository — Login Service Tests', () {
    late MockApiService mockApi;
    late MockStorageService mockStorage;
    late AuthRepository authRepo;

    setUp(() {
      mockApi = MockApiService();
      mockStorage = MockStorageService();
      authRepo = AuthRepository(
        apiService: mockApi,
        storageService: mockStorage,
      );
    });

    test('login() returns UserModel on success', () async {
      final user = await authRepo.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.role, 'admin');
      expect(user.token, 'test_token_abc');
    });

    test('login() saves token to storage on success', () async {
      await authRepo.login(
        email: 'test@example.com',
        password: 'secret',
      );

      final savedToken = await mockStorage.getAuthToken();
      expect(savedToken, 'test_token_abc');
    });

    test('login() saves user to storage on success', () async {
      await authRepo.login(
        email: 'admin@test.com',
        password: 'password',
      );

      final savedUser = await mockStorage.getUser();
      expect(savedUser, isNotNull);
      expect(savedUser!.email, 'admin@test.com');
    });

    test('login() throws AppException on API failure', () async {
      mockApi.shouldFailLogin = true;

      expect(
        () => authRepo.login(email: 'bad@test.com', password: 'wrong'),
        throwsA(isA<Exception>()),
      );
    });

    test('logout() clears storage', () async {
      // First login
      await authRepo.login(email: 'test@example.com', password: 'pass');
      expect(await mockStorage.getAuthToken(), isNotNull);

      // Then logout
      await authRepo.logout();
      expect(await mockStorage.getAuthToken(), isNull);
      expect(await mockStorage.getUser(), isNull);
    });

    test('getStoredUser() returns null when no token', () async {
      final user = await authRepo.getStoredUser();
      expect(user, isNull);
    });

    test('getStoredUser() returns user when token exists', () async {
      await authRepo.login(email: 'test@example.com', password: 'pass');
      final storedUser = await authRepo.getStoredUser();
      expect(storedUser, isNotNull);
    });

    test('isLoggedIn() returns false before login', () async {
      final result = await authRepo.isLoggedIn();
      expect(result, false);
    });

    test('isLoggedIn() returns true after login', () async {
      await authRepo.login(email: 'test@example.com', password: 'pass');
      final result = await authRepo.isLoggedIn();
      expect(result, true);
    });
  });

  // ── Customer Repository Tests ───────────────────────────────────────────────

  group('CustomerRepository — Customer Repository Tests', () {
    late MockApiService mockApi;
    late CustomerRepository customerRepo;

    setUp(() {
      mockApi = MockApiService();
      customerRepo = CustomerRepository(apiService: mockApi);
    });

    test('getCustomers() returns CustomerListResult', () async {
      final result = await customerRepo.getCustomers();

      expect(result.customers, isNotEmpty);
      expect(result.total, 2);
      expect(result.currentPage, 1);
    });

    test('getCustomers() parses CustomerModel correctly', () async {
      final result = await customerRepo.getCustomers();
      final first = result.customers.first;

      expect(first.id, 'c1');
      expect(first.name, 'Alice Smith');
      expect(first.email, 'alice@example.com');
      expect(first.phone, '+94 71 555 0001');
      expect(first.status, CustomerStatus.active);
    });

    test('getCustomers() search filters by name', () async {
      final result = await customerRepo.getCustomers(search: 'Alice');

      expect(result.customers.length, 1);
      expect(result.customers.first.name, 'Alice Smith');
    });

    test('getCustomers() search with no match returns empty', () async {
      final result = await customerRepo.getCustomers(search: 'ZZZ_NO_MATCH');

      expect(result.customers, isEmpty);
    });

    test('getCustomers() hasMore is true when results equal limit', () async {
      final result = await customerRepo.getCustomers(limit: 2);
      expect(result.hasMore, true);
    });

    test('getCustomers() hasMore is false when results less than limit',
        () async {
      final result = await customerRepo.getCustomers(limit: 10);
      expect(result.hasMore, false);
    });

    test('getCustomers() throws on API failure', () async {
      mockApi.shouldFailCustomers = true;

      expect(
        () => customerRepo.getCustomers(),
        throwsA(isA<Exception>()),
      );
    });

    test('CustomerModel.fromJson parses phone correctly', () {
      final json = {
        'id': 'c99',
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '+94 76 123 4567',
        'total_purchases': 999.99,
        'last_purchase_date': '2024-03-15T00:00:00Z',
        'status': 'active',
      };

      final model = CustomerModel.fromJson(json);

      expect(model.phone, '+94 76 123 4567');
      expect(model.name, 'John Doe');
    });

    test('CustomerModel status defaults to active for unknown status', () {
      final json = {
        'id': 'cx',
        'name': 'Unknown',
        'email': 'u@u.com',
        'phone': '000',
        'total_purchases': 0.0,
        'last_purchase_date': '2024-01-01T00:00:00Z',
        'status': 'unknown_status',
      };

      final model = CustomerModel.fromJson(json);
      expect(model.status, CustomerStatus.active);
    });
  });
}
