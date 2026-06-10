import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../utils/app_constants.dart';
import '../utils/app_exceptions.dart';
import 'storage_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService);
});

class ApiService {
  ApiService(this._storageService) {
    _init();
  }

  final StorageService _storageService;
  late final Dio _dio;

  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 — token expired
          if (error.response?.statusCode == 401) {
            await _storageService.clearAll();
            // The router will redirect to login via authProvider
          }
          handler.next(error);
        },
      ),
    );

    // Logging (debug only)
    assert(() {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
      return true;
    }());

    // Mock Interceptor to handle fake responses
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == AppConstants.loginEndpoint) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'token': 'mock_token_123',
                  'user': {
                    'id': 'u1',
                    'name': 'Alex Johnson',
                    'email': options.data['email'],
                    'role': 'admin',
                  }
                },
              ),
            );
          }
          if (options.path == AppConstants.dashboardEndpoint) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'total_revenue': 50000.00,
                  'total_orders': 450,
                  'total_customers': 120,
                  'revenue_growth': 12.4,
                  'orders_growth': 8.2,
                  'customers_growth': 5.7,
                  'recent_sales': [
                    {'month': 1, 'year': 2024, 'revenue': 15000.0, 'orders': 40},
                    {'month': 2, 'year': 2024, 'revenue': 18500.0, 'orders': 52},
                    {'month': 3, 'year': 2024, 'revenue': 16200.0, 'orders': 45},
                    {'month': 4, 'year': 2024, 'revenue': 21000.0, 'orders': 60},
                    {'month': 5, 'year': 2024, 'revenue': 19800.0, 'orders': 55},
                    {'month': 6, 'year': 2024, 'revenue': 34000.0, 'orders': 90},
                  ],
                },
              ),
            );
          }
          if (options.path == AppConstants.customersEndpoint) {
            final search = options.queryParameters['search'] as String?;
            final baseCustomers = [
              {
                'id': 'c1', 'name': 'Sarah Williams', 'email': 'sarah@example.com',
                'phone': '+94 71 234 5678', 'total_purchases': 4200.50,
                'last_purchase_date': '2024-05-15T10:00:00Z',
                'status': 'active', 'address': '123 Main St, NY'
              },
              {
                'id': 'c2', 'name': 'James Miller', 'email': 'james@example.com',
                'phone': '+94 77 345 6789', 'total_purchases': 8750.00,
                'last_purchase_date': '2024-04-22T10:00:00Z',
                'status': 'active', 'address': '456 Oak Ave, CA'
              },
              {
                'id': 'c3', 'name': 'Emily Davis', 'email': 'emily@example.com',
                'phone': '+94 75 456 7890', 'total_purchases': 1250.75,
                'last_purchase_date': '2024-03-10T10:00:00Z',
                'status': 'inactive', 'address': '789 Pine Rd, TX'
              },
              {
                'id': 'c4', 'name': 'Michael Brown', 'email': 'michael@example.com',
                'phone': '+94 76 567 8901', 'total_purchases': 3400.00,
                'last_purchase_date': '2024-05-28T10:00:00Z',
                'status': 'active', 'address': '321 Elm St, FL'
              },
              {
                'id': 'c5', 'name': 'Jessica Taylor', 'email': 'jessica@example.com',
                'phone': '+94 78 678 9012', 'total_purchases': 650.00,
                'last_purchase_date': '2024-01-05T10:00:00Z',
                'status': 'suspended', 'address': '654 Maple Dr, WA'
              },
              {
                'id': 'c6', 'name': 'David Anderson', 'email': 'david@example.com',
                'phone': '+94 72 789 0123', 'total_purchases': 12000.00,
                'last_purchase_date': '2024-06-01T10:00:00Z',
                'status': 'active', 'address': '987 Cedar Ln, IL'
              },
              {
                'id': 'c7', 'name': 'Amanda Wilson', 'email': 'amanda@example.com',
                'phone': '+94 70 890 1234', 'total_purchases': 2100.25,
                'last_purchase_date': '2024-05-10T10:00:00Z',
                'status': 'active', 'address': '147 Birch Blvd, OH'
              },
              {
                'id': 'c8', 'name': 'Robert Martinez', 'email': 'robert@example.com',
                'phone': '+94 74 901 2345', 'total_purchases': 5500.00,
                'last_purchase_date': '2024-04-15T10:00:00Z',
                'status': 'inactive', 'address': '258 Spruce Way, AZ'
              },
              {
                'id': 'c9', 'name': 'Lisa Thompson', 'email': 'lisa@example.com',
                'phone': '+94 71 012 3456', 'total_purchases': 9800.00,
                'last_purchase_date': '2024-06-05T10:00:00Z',
                'status': 'active', 'address': '369 Walnut St, CO'
              },
            ];
            
            final allCustomers = [
              ...baseCustomers,
              ...List.generate(111, (index) => {
                'id': 'c${index + 10}',
                'name': 'Customer ${index + 10}',
                'email': 'customer${index + 10}@example.com',
                'phone': '+94 71 000 ${index.toString().padLeft(4, '0')}',
                'total_purchases': (index * 100.0) + 50.0,
                'last_purchase_date': '2024-06-01T10:00:00Z',
                'status': index % 5 == 0 ? 'inactive' : 'active',
                'address': '${index + 10} Main St, City'
              })
            ];
            final filtered = search != null && search.isNotEmpty
                ? allCustomers.where((c) => (c['name'] as String)
                    .toLowerCase()
                    .contains(search.toLowerCase()))
                    .toList()
                : allCustomers;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'customers': filtered,
                  'total': filtered.length,
                },
              ),
            );
          }
          if (options.path == AppConstants.reportsEndpoint) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'report': {
                    'id': 'r1',
                    'title': 'Monthly Sales Report',
                    'period': 'monthly',
                    'total_revenue': 50000.00,
                    'total_orders': 450,
                    'total_customers': 120,
                    'growth_rate': 12.4,
                    'generated_at': '2024-06-10T00:00:00Z',
                    'monthly_sales': [
                      {'month': 1, 'year': 2024, 'revenue': 5000.0, 'orders': 45},
                      {'month': 2, 'year': 2024, 'revenue': 6500.0, 'orders': 58},
                      {'month': 3, 'year': 2024, 'revenue': 7200.0, 'orders': 65},
                      {'month': 4, 'year': 2024, 'revenue': 8100.0, 'orders': 73},
                      {'month': 5, 'year': 2024, 'revenue': 9400.0, 'orders': 85},
                      {'month': 6, 'year': 2024, 'revenue': 13800.0, 'orders': 124},
                    ],
                    'top_products': [
                      {'name': 'Enterprise Suite', 'revenue': 18000.0, 'units': 15, 'percentage': 36.0},
                      {'name': 'Pro Plan', 'revenue': 12850.0, 'units': 64, 'percentage': 25.7},
                      {'name': 'Starter Kit', 'revenue': 9650.0, 'units': 120, 'percentage': 19.3},
                      {'name': 'Add-ons Bundle', 'revenue': 6000.0, 'units': 75, 'percentage': 12.0},
                      {'name': 'Support Package', 'revenue': 3500.0, 'units': 34, 'percentage': 7.0},
                    ],
                  }
                },
              ),
            );
          }
          handler.next(options);
        },
      ),
    );
  }

  // ── Auth ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(AppConstants.logoutEndpoint);
    } on DioException catch (e) {
      // Silently handle logout errors — clear local storage regardless
      if (e.response?.statusCode != 401) {
        throw _handleDioError(e);
      }
    }
  }

  // ── Customers ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.customersEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null) 'status': status,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCustomerById(String id) async {
    try {
      final response = await _dio.get(
        '${AppConstants.customersEndpoint}/$id',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Reports ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getReports({
    String period = 'monthly',
    int? year,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.reportsEndpoint,
        queryParameters: {
          'period': period,
          if (year != null) 'year': year,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get(AppConstants.dashboardEndpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Error Handling ──────────────────────────────────────────────────────────

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please try again.',
        );
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      case DioExceptionType.cancel:
        return const AppException('Request was cancelled.');
      default:
        return AppException(
          error.message ?? 'An unexpected error occurred.',
        );
    }
  }

  AppException _handleResponseError(Response? response) {
    if (response == null) {
      return const AppException('No response from server.');
    }

    final statusCode = response.statusCode;
    final data = response.data;
    final message = data is Map ? data['message'] as String? : null;

    switch (statusCode) {
      case 400:
        return ValidationException(message ?? 'Invalid request.');
      case 401:
        return const AuthException('Session expired. Please log in again.');
      case 403:
        return const AuthException('You do not have permission to do that.');
      case 404:
        return NotFoundException(message ?? 'Resource not found.');
      case 422:
        return ValidationException(message ?? 'Validation failed.');
      case 429:
        return const NetworkException('Too many requests. Please slow down.');
      case 500:
      case 502:
      case 503:
        return const ServerException('Server error. Please try again later.');
      default:
        return AppException(message ?? 'Unexpected error ($statusCode).');
    }
  }
}
