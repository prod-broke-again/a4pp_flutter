List<String> _parseFeatures(dynamic features) {
  if (features is List<dynamic>) {
    // Если features - массив, обрабатываем как обычно
    return features.map((e) => e.toString()).toList();
  } else if (features is Map<String, dynamic>) {
    // Если features - объект, берем значения и сортируем по ключам
    final sortedKeys = features.keys.toList()..sort();
    return sortedKeys.map((key) => features[key].toString()).toList();
  } else {
    // Если features - что-то другое или null, возвращаем пустой список
    return const [];
  }
}

class Product {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final String currency;
  final int durationDays;
  final String level;
  final List<String> features;
  final bool isActive;
  final bool isTrial;
  final int trialDays;
  final int sortOrder;
  final bool hasCoursesAccess;
  final bool hasClubsAccess;
  final bool hasVideoLibraryAccess;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? formattedPrice;
  final String? monthlyPrice;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.level,
    required this.features,
    required this.isActive,
    required this.isTrial,
    required this.trialDays,
    required this.sortOrder,
    required this.hasCoursesAccess,
    required this.hasClubsAccess,
    required this.hasVideoLibraryAccess,
    required this.createdAt,
    required this.updatedAt,
    this.formattedPrice,
    this.monthlyPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawLevel = json['level'];
    String levelStr;
    if (rawLevel is int) {
      // Простое соответствие уровней названиям
      if (rawLevel >= 3) {
        levelStr = 'Premium';
      } else if (rawLevel == 2) {
        levelStr = 'Basic';
      } else {
        levelStr = 'Trial';
      }
    } else {
      levelStr = (rawLevel ?? '').toString();
    }

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: json['description']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      currency: (json['currency'] ?? 'RUB').toString(),
      durationDays: int.tryParse(json['duration_days']?.toString() ?? '') ?? (json['duration_days'] as int? ?? 0),
      level: levelStr,
      features: _parseFeatures(json['features']),
      isActive: json['is_active'] == true,
      isTrial: json['is_trial'] == true,
      trialDays: int.tryParse(json['trial_days']?.toString() ?? '') ?? (json['trial_days'] as int? ?? 0),
      sortOrder: int.tryParse(json['sort_order']?.toString() ?? '') ?? (json['sort_order'] as int? ?? 0),
      hasCoursesAccess: (json['permissions']?.toString() ?? '').contains('courses'),
      hasClubsAccess: (json['permissions']?.toString() ?? '').contains('clubs'),
      hasVideoLibraryAccess: (json['permissions']?.toString() ?? '').contains('videos'),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      formattedPrice: json['formatted_price'] as String?,
      monthlyPrice: json['monthly_price'] as String?,
    );
  }
}
