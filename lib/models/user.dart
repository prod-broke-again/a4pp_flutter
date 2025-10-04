import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

bool _boolFromJson(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.toLowerCase().trim();
    return v == '1' || v == 'true' || v == 'yes';
  }
  return false;
}

DateTime _dateTimeFromJson(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  final s = value.toString();
  return DateTime.tryParse(s) ?? DateTime.now();
}

dynamic _readAvatar(Map<dynamic, dynamic> json, String key) {
  return json['avatar'] ?? json['avatar_url'];
}

@JsonSerializable()
class User {
  final int id;
  final String? firstname;
  final String? lastname;
  final String email;
  final String? phone;
  final String? bio;
  @JsonKey(name: 'avatar', readValue: _readAvatar)
  final String? avatar;
  final double balance;
  @JsonKey(name: 'formatted_balance')
  final String? formattedBalance;
  @JsonKey(name: 'email_verified_at')
  final DateTime? emailVerifiedAt;
  @JsonKey(fromJson: _boolFromJson)
  final bool auto;
  @JsonKey(name: 'psy_lance', fromJson: _boolFromJson)
  final bool psyLance;
  final Role role;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)
  final DateTime updatedAt;

  User({
    required this.id,
    this.firstname,
    this.lastname,
    required this.email,
    this.phone,
    this.bio,
    this.avatar,
    required this.balance,
    this.formattedBalance,
    this.emailVerifiedAt,
    required this.auto,
    required this.psyLance,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // Обработка разных форматов (стандартный vs новости)
      final firstname = json['firstname'] as String?;
      final lastname = json['lastname'] as String?;
      final name = json['name'] as String?;
      final rawAvatar = json['avatar']?.toString() ?? json['avatar_url']?.toString();
      final avatar = rawAvatar != null && !rawAvatar.startsWith('http')
          ? 'https://appp-psy.ru$rawAvatar'
          : rawAvatar;

      // Если есть поле name (как в новостях), разобьем его на firstname/lastname
      String? finalFirstname = firstname;
      String? finalLastname = lastname;
      if (name != null && firstname == null && lastname == null) {
        final parts = name.split(' ');
        if (parts.length >= 2) {
          finalFirstname = parts[0];
          finalLastname = parts.sublist(1).join(' ');
        } else {
          finalFirstname = name;
        }
      }

      // Создаем временный JSON с правильными полями и значениями по умолчанию
      final normalizedJson = Map<String, dynamic>.from(json);
      normalizedJson['firstname'] = finalFirstname;
      normalizedJson['lastname'] = finalLastname;
      normalizedJson['avatar'] = avatar;

      // Добавляем значения по умолчанию для отсутствующих полей
      normalizedJson['email'] = normalizedJson['email'] ?? '';
      normalizedJson['balance'] = normalizedJson['balance'] ?? 0.0;
      normalizedJson['formatted_balance'] = normalizedJson['formatted_balance'] ?? '';
      normalizedJson['auto'] = normalizedJson['auto'] ?? false;
      normalizedJson['psy_lance'] = normalizedJson['psy_lance'] ?? false;
      normalizedJson['role'] = normalizedJson['role'] ?? {'name': 'Пользователь', 'color': '#6B46C1'};
      normalizedJson['phone'] = normalizedJson['phone'] ?? null;
      normalizedJson['bio'] = normalizedJson['bio'] ?? null;

      return _$UserFromJson(normalizedJson);
    } catch (e) {
      print('Ошибка в User.fromJson: $e');
      print('JSON: $json');
      rethrow;
    }
  }
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '${firstname ?? ''} ${lastname ?? ''}'.trim();
}

@JsonSerializable()
class Role {
  final String name;
  final String color;

  Role({required this.name, required this.color});

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
