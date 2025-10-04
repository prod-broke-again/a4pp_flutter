import 'package:mobile/models/product.dart';
import 'package:mobile/models/user.dart';

class Subscription {
  final int id;
  final int userId;
  final int productId;
  final String status;
  final DateTime startsAt;
  final DateTime expiresAt;
  final DateTime? cancelledAt;
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String? paymentId;
  final DateTime? trialEndsAt;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final Product? product;

  Subscription({
    required this.id,
    required this.userId,
    required this.productId,
    required this.status,
    required this.startsAt,
    required this.expiresAt,
    this.cancelledAt,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    this.paymentId,
    this.trialEndsAt,
    required this.autoRenew,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.product,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      productId: json['product_id'] as int,
      status: json['status'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at'] as String) : null,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethod: json['payment_method'] as String?,
      paymentId: json['payment_id'] as String?,
      trialEndsAt: json['trial_ends_at'] != null ? DateTime.parse(json['trial_ends_at'] as String) : null,
      autoRenew: json['auto_renew'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'status': status,
      'starts_at': startsAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_id': paymentId,
      'trial_ends_at': trialEndsAt?.toIso8601String(),
      'auto_renew': autoRenew,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'product': product?.toJson(),
    };
  }
}
