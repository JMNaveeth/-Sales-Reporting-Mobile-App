import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';

// ── State ────────────────────────────────────────────────────────────────────

class CustomersState {
  const CustomersState({
    this.customers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.searchQuery = '',
    this.selectedStatus,
    this.currentPage = 1,
    this.hasMore = true,
    this.total = 0,
  });

  final List<CustomerModel> customers;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String searchQuery;
  final CustomerStatus? selectedStatus;
  final int currentPage;
  final bool hasMore;
  final int total;

  CustomersState copyWith({
    List<CustomerModel>? customers,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? searchQuery,
    CustomerStatus? selectedStatus,
    bool clearStatus = false,
    int? currentPage,
    bool? hasMore,
    int? total,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: clearStatus ? null : selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

final customersProvider =
    StateNotifierProvider<CustomersNotifier, CustomersState>((ref) {
  return CustomersNotifier(ref.watch(customerRepositoryProvider));
});

class CustomersNotifier extends StateNotifier<CustomersState> {
  CustomersNotifier(this._repository) : super(const CustomersState()) {
    loadCustomers();
  }

  final CustomerRepository _repository;
  static const int _pageSize = 20;

  Future<void> loadCustomers({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getCustomers(
        page: 1,
        limit: _pageSize,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        status: state.selectedStatus?.value,
      );

      state = state.copyWith(
        customers: result.customers,
        isLoading: false,
        currentPage: 1,
        hasMore: result.hasMore,
        total: result.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _repository.getCustomers(
        page: state.currentPage + 1,
        limit: _pageSize,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        status: state.selectedStatus?.value,
      );

      state = state.copyWith(
        customers: [...state.customers, ...result.customers],
        isLoadingMore: false,
        currentPage: state.currentPage + 1,
        hasMore: result.hasMore,
        total: result.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    loadCustomers();
  }

  void filterByStatus(CustomerStatus? status) {
    state = state.copyWith(
      selectedStatus: status,
      clearStatus: status == null,
    );
    loadCustomers();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
