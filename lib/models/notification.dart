class Notification {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notification({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Notification copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? data,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Геттеры для удобства
  bool get isRead => readAt != null;
  String get message => data['message'] ?? 'Уведомление';
  String? get actionUrl => data['action_url'];
  String? get userName => data['user_name'];
}
