import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_model.dart';
import '../services/api_service.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(apiService: ref.watch(apiServiceProvider));
});

class CustomerRepository {
  const CustomerRepository({required this.apiService});

  final ApiService apiService;

  Future<CustomerListResult> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    final data = await apiService.getCustomers(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );

    final customers = (data['customers'] as List<dynamic>? ?? [])
        .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return CustomerListResult(
      customers: customers,
      total: (data['total'] as num?)?.toInt() ?? customers.length,
      currentPage: page,
      hasMore: customers.length == limit,
    );
  }

  Future<CustomerModel> getCustomerById(String id) async {
    final data = await apiService.getCustomerById(id);
    return CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
  }
}

class CustomerListResult {
  const CustomerListResult({
    required this.customers,
    required this.total,
    required this.currentPage,
    required this.hasMore,
  });

  final List<CustomerModel> customers;
  final int total;
  final int currentPage;
  final bool hasMore;
}
