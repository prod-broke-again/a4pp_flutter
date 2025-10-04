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
    // Проверяем обязательные поля
    final id = json['id'];
    final type = json['type'];
    final createdAtStr = json['created_at'];
    final updatedAtStr = json['updated_at'];

    if (id == null || type == null || createdAtStr == null || updatedAtStr == null) {
      throw FormatException('Missing required fields in notification JSON');
    }

    return Notification(
      id: id as String,
      type: type as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(createdAtStr as String),
      updatedAt: DateTime.parse(updatedAtStr as String),
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

  String get message {
    final msg = data['message'];
    if (msg is String) return msg;
    return 'Уведомление';
  }

  String? get actionUrl {
    final url = data['action_url'];
    if (url is String) return url;
    return null;
  }

  String? get userName {
    final name = data['user_name'];
    if (name is String) return name;
    return null;
  }

  String get title {
    final title = data['title'];
    if (title is String) return title;
    return message; // fallback to message if no title
  }
}
