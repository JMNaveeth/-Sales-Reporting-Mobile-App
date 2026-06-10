import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../repositories/report_repository.dart';

// ── Dashboard Stats ──────────────────────────────────────────────────────────

final dashboardStatsProvider =
    StateNotifierProvider<DashboardStatsNotifier, AsyncValue<DashboardStats>>(
  (ref) => DashboardStatsNotifier(ref.watch(reportRepositoryProvider)),
);

class DashboardStatsNotifier
    extends StateNotifier<AsyncValue<DashboardStats>> {
  DashboardStatsNotifier(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final ReportRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getDashboardStats());
  }

  Future<void> refresh() => load();
}

// ── Reports ──────────────────────────────────────────────────────────────────

class ReportsState {
  const ReportsState({
    this.report,
    this.isLoading = false,
    this.error,
    this.selectedPeriod = ReportPeriod.monthly,
    this.selectedYear,
  });

  final ReportModel? report;
  final bool isLoading;
  final String? error;
  final ReportPeriod selectedPeriod;
  final int? selectedYear;

  ReportsState copyWith({
    ReportModel? report,
    bool? isLoading,
    String? error,
    ReportPeriod? selectedPeriod,
    int? selectedYear,
  }) {
    return ReportsState(
      report: report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(ref.watch(reportRepositoryProvider));
});

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier(this._repository) : super(const ReportsState()) {
    loadReport();
  }

  final ReportRepository _repository;

  Future<void> loadReport() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final report = await _repository.getReport(
        period: state.selectedPeriod.value,
        year: state.selectedYear,
      );
      state = state.copyWith(report: report, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void changePeriod(ReportPeriod period) {
    state = state.copyWith(selectedPeriod: period);
    loadReport();
  }

  void changeYear(int year) {
    state = state.copyWith(selectedYear: year);
    loadReport();
  }
}
