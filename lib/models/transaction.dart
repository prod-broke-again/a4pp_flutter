import 'package:achpp/models/user.dart';

class Transaction {
  final int id;
  final int userId;
  final String type;
  final double amount;
  final String currency;
  final String description;
  final String status;
  final String? paymentMethod;
  final String? paymentId;
  final String? relatedType;
  final int? relatedId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.status,
    this.paymentMethod,
    this.paymentId,
    this.relatedType,
    this.relatedId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'RUB',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString(),
      paymentId: json['payment_id']?.toString(),
      relatedType: json['related_type']?.toString(),
      relatedId: json['related_id'] as int?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}
