import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalPurchases,
    required this.lastPurchaseDate,
    this.avatarUrl,
    this.status = CustomerStatus.active,
    this.address,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final double totalPurchases;
  final DateTime lastPurchaseDate;
  final String? avatarUrl;
  final CustomerStatus status;
  final String? address;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      totalPurchases: (json['total_purchases'] as num?)?.toDouble() ?? 0.0,
      lastPurchaseDate: json['last_purchase_date'] != null
          ? DateTime.tryParse(json['last_purchase_date'] as String) ??
              DateTime.now()
          : DateTime.now(),
      avatarUrl: json['avatar_url'] as String?,
      status: CustomerStatus.fromString(json['status'] as String? ?? 'active'),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'total_purchases': totalPurchases,
      'last_purchase_date': lastPurchaseDate.toIso8601String(),
      'avatar_url': avatarUrl,
      'status': status.value,
      'address': address,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    double? totalPurchases,
    DateTime? lastPurchaseDate,
    String? avatarUrl,
    CustomerStatus? status,
    String? address,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, phone, totalPurchases, lastPurchaseDate, status];
}

enum CustomerStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended');

  const CustomerStatus(this.value);
  final String value;

  static CustomerStatus fromString(String value) {
    return CustomerStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CustomerStatus.active,
    );
  }
}
