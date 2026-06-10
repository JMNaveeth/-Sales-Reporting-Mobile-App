import 'package:equatable/equatable.dart';

class ReportModel extends Equatable {
  const ReportModel({
    required this.id,
    required this.title,
    required this.period,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalCustomers,
    required this.growthRate,
    required this.monthlySales,
    required this.topProducts,
    required this.generatedAt,
  });

  final String id;
  final String title;
  final ReportPeriod period;
  final double totalRevenue;
  final int totalOrders;
  final int totalCustomers;
  final double growthRate; // percentage
  final List<MonthlySale> monthlySales;
  final List<TopProduct> topProducts;
  final DateTime generatedAt;

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      period: ReportPeriod.fromString(json['period'] as String? ?? 'monthly'),
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalCustomers: (json['total_customers'] as num?)?.toInt() ?? 0,
      growthRate: (json['growth_rate'] as num?)?.toDouble() ?? 0.0,
      monthlySales: (json['monthly_sales'] as List<dynamic>?)
              ?.map((e) => MonthlySale.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topProducts: (json['top_products'] as List<dynamic>?)
              ?.map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'period': period.value,
        'total_revenue': totalRevenue,
        'total_orders': totalOrders,
        'total_customers': totalCustomers,
        'growth_rate': growthRate,
        'monthly_sales': monthlySales.map((e) => e.toJson()).toList(),
        'top_products': topProducts.map((e) => e.toJson()).toList(),
        'generated_at': generatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, period, totalRevenue, generatedAt];
}

class MonthlySale extends Equatable {
  const MonthlySale({
    required this.month,
    required this.year,
    required this.revenue,
    required this.orders,
  });

  final int month;
  final int year;
  final double revenue;
  final int orders;

  factory MonthlySale.fromJson(Map<String, dynamic> json) {
    return MonthlySale(
      month: (json['month'] as num?)?.toInt() ?? 1,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'year': year,
        'revenue': revenue,
        'orders': orders,
      };

  @override
  List<Object?> get props => [month, year, revenue, orders];
}

class TopProduct extends Equatable {
  const TopProduct({
    required this.name,
    required this.revenue,
    required this.units,
    required this.percentage,
  });

  final String name;
  final double revenue;
  final int units;
  final double percentage;

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      name: json['name'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      units: (json['units'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'revenue': revenue,
        'units': units,
        'percentage': percentage,
      };

  @override
  List<Object?> get props => [name, revenue, units, percentage];
}

enum ReportPeriod {
  weekly('weekly'),
  monthly('monthly'),
  quarterly('quarterly'),
  yearly('yearly');

  const ReportPeriod(this.value);
  final String value;

  static ReportPeriod fromString(String value) {
    return ReportPeriod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportPeriod.monthly,
    );
  }

  String get label {
    switch (this) {
      case ReportPeriod.weekly:
        return 'Weekly';
      case ReportPeriod.monthly:
        return 'Monthly';
      case ReportPeriod.quarterly:
        return 'Quarterly';
      case ReportPeriod.yearly:
        return 'Yearly';
    }
  }
}
