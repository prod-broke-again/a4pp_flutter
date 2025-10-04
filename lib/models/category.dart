class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int? parentId;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Category>? children;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Без названия',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      parentId: json['parent_id'] as int?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
      children: json['children'] != null
          ? (json['children'] as List<dynamic>? ?? []).map((child) => Category.fromJson(child as Map<String, dynamic>)).toList()
          : null,
    );
  }
}
