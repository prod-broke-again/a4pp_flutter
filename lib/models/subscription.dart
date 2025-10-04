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
}
