import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../services/api_service.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(apiService: ref.watch(apiServiceProvider));
});

class ReportRepository {
  const ReportRepository({required this.apiService});

  final ApiService apiService;

  Future<ReportModel> getReport({
    String period = 'monthly',
    int? year,
  }) async {
    final data = await apiService.getReports(period: period, year: year);
    return ReportModel.fromJson(data['report'] as Map<String, dynamic>);
  }

  Future<DashboardStats> getDashboardStats() async {
    final data = await apiService.getDashboardStats();
    return DashboardStats.fromJson(data);
  }
}

/// Lightweight summary data for the dashboard
class DashboardStats {
  const DashboardStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalCustomers,
    required this.revenueGrowth,
    required this.ordersGrowth,
    required this.customersGrowth,
    required this.recentSales,
  });

  final double totalRevenue;
  final int totalOrders;
  final int totalCustomers;
  final double revenueGrowth;
  final double ordersGrowth;
  final double customersGrowth;
  final List<MonthlySale> recentSales;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalCustomers: (json['total_customers'] as num?)?.toInt() ?? 0,
      revenueGrowth: (json['revenue_growth'] as num?)?.toDouble() ?? 0.0,
      ordersGrowth: (json['orders_growth'] as num?)?.toDouble() ?? 0.0,
      customersGrowth: (json['customers_growth'] as num?)?.toDouble() ?? 0.0,
      recentSales: (json['recent_sales'] as List<dynamic>?)
              ?.map((e) => MonthlySale.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convenience — mock fallback for UI testing without a live API
  static DashboardStats mock() {
    return DashboardStats(
      totalRevenue: 50000.00,
      totalOrders: 450,
      totalCustomers: 120,
      revenueGrowth: 12.4,
      ordersGrowth: 8.2,
      customersGrowth: 5.7,
      recentSales: List.generate(
        6,
        (i) => MonthlySale(
          month: DateTime.now().month - i,
          year: DateTime.now().year,
          revenue: 15000 + (i * 2000).toDouble(),
          orders: 40 + i * 5,
        ),
      ).reversed.toList(),
    );
  }
}
