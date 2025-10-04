import 'package:mobile/models/product.dart';
import 'package:mobile/models/subscription.dart';
import 'package:mobile/models/user.dart';

class ProfileData {
  final User user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;
  final List<Map<String, dynamic>> notifications;
  final int unreadNotificationsCount;

  ProfileData({
    required this.user,
    required this.subscriptionStatus,
    required this.products,
    this.notifications = const [],
    this.unreadNotificationsCount = 0,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    try {
      final user = User.fromJson(json['user'] as Map<String, dynamic>);

      final subStatusJson = json['subscription_status'];

      // Обработка products: может быть List, Map или null
      List<dynamic> productsJson;
      final rawProducts = json['products'];

      if (rawProducts is List<dynamic>) {
        productsJson = rawProducts;
      } else if (rawProducts is Map<String, dynamic>) {
        // Если products - объект, берем значения
        productsJson = rawProducts.values.toList();
      } else {
        productsJson = const [];
      }

      final products = productsJson
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();

      // Парсим уведомления: приходит как объект пагинации {current_page, data: [...], ...}
      List<dynamic> notificationsJson;
      final rawNotifications = json['notifications'];

      if (rawNotifications is Map<String, dynamic>) {
        // Извлекаем массив уведомлений из поля 'data'
        final notificationsData = rawNotifications['data'];
        if (notificationsData is List<dynamic>) {
          notificationsJson = notificationsData;
        } else {
          notificationsJson = const [];
        }
      } else if (rawNotifications is List<dynamic>) {
        // На случай, если вдруг придет как массив
        notificationsJson = rawNotifications;
      } else {
        notificationsJson = const [];
      }

      final notifications = notificationsJson
          .map((e) => e as Map<String, dynamic>)
          .toList();

      final unreadNotificationsCount = json['unread_notifications_count'];
      final unreadCount = unreadNotificationsCount as int? ?? 0;

      return ProfileData(
        user: user,
        subscriptionStatus: subStatusJson != null && subStatusJson is Map<String, dynamic>
            ? SubscriptionStatus.fromJson(subStatusJson)
            : null,
        products: products,
        notifications: notifications,
        unreadNotificationsCount: unreadCount,
      );
    } catch (e, stackTrace) {
      print('❌ ProfileData.fromJson: ошибка парсинга: $e');
      print('❌ ProfileData.fromJson: стек вызовов: $stackTrace');
      print('❌ ProfileData.fromJson: полный JSON: $json');
      rethrow;
    }
  }
}

class SubscriptionStatus {
  final bool isActive;
  final int? level;
  final String? productName;
  final DateTime? expiresAt;
  final bool auto;
  final Subscription? subscription;
  final Product? product;

  SubscriptionStatus({
    required this.isActive,
    this.level,
    this.productName,
    this.expiresAt,
    required this.auto,
    this.subscription,
    this.product,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    final expiresRaw = json['expiresAt']?.toString();
    DateTime? expires;
    if (expiresRaw != null && expiresRaw.isNotEmpty) {
      // Форматы могут быть '2025-10-10 22:21:21' или ISO8601
      expires = DateTime.tryParse(expiresRaw.replaceFirst(' ', 'T')) ?? DateTime.tryParse(expiresRaw);
    }

    // Сконструируем Subscription максимально полно из имеющихся данных
    Subscription? sub;
    final subJson = json['subscription'] as Map<String, dynamic>?;
    if (subJson != null) {
      sub = Subscription(
        id: (subJson['id'] ?? 0) as int,
        userId: 0,
        productId: (json['product']?['id'] ?? 0) as int,
        status: (subJson['status'] ?? '').toString(),
        startsAt: DateTime.tryParse((subJson['starts_at']?.toString() ?? '').replaceFirst(' ', 'T')) ?? DateTime.now(),
        expiresAt: DateTime.tryParse((subJson['expires_at']?.toString() ?? '').replaceFirst(' ', 'T')) ?? (expires ?? DateTime.now()),
        cancelledAt: DateTime.tryParse(subJson['cancelled_at']?.toString() ?? ''),
        amount: double.tryParse(subJson['amount']?.toString() ?? '0') ?? 0,
        currency: (subJson['currency'] ?? 'RUB').toString(),
        paymentMethod: subJson['payment_method']?.toString(),
        paymentId: subJson['payment_id']?.toString(),
        trialEndsAt: DateTime.tryParse(subJson['trial_ends_at']?.toString() ?? ''),
        autoRenew: (json['auto'] ?? false) == true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        user: null,
        product: json['product'] != null ? Product.fromJson(json['product'] as Map<String, dynamic>) : null,
      );
    }

    return SubscriptionStatus(
      isActive: json['isActive'] == true,
      level: json['level'] as int?,
      productName: json['productName']?.toString(),
      expiresAt: expires,
      auto: json['auto'] == true,
      subscription: sub,
      product: json['product'] != null ? Product.fromJson(json['product'] as Map<String, dynamic>) : null,
    );
  }
}


