// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  firstname: json['firstname'] as String?,
  lastname: json['lastname'] as String?,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  bio: json['bio'] as String?,
  avatar: _readAvatar(json, 'avatar') as String?,
  balance: (json['balance'] as num).toDouble(),
  formattedBalance: json['formatted_balance'] as String?,
  emailVerifiedAt: json['email_verified_at'] == null
      ? null
      : DateTime.parse(json['email_verified_at'] as String),
  auto: _boolFromJson(json['auto']),
  psyLance: _boolFromJson(json['psy_lance']),
  role: Role.fromJson(json['role'] as Map<String, dynamic>),
  createdAt: _dateTimeFromJson(json['created_at']),
  updatedAt: _dateTimeFromJson(json['updated_at']),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstname': instance.firstname,
  'lastname': instance.lastname,
  'email': instance.email,
  'phone': instance.phone,
  'bio': instance.bio,
  'avatar': instance.avatar,
  'balance': instance.balance,
  'formatted_balance': instance.formattedBalance,
  'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
  'auto': instance.auto,
  'psy_lance': instance.psyLance,
  'role': instance.role,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

Role _$RoleFromJson(Map<String, dynamic> json) =>
    Role(name: json['name'] as String, color: json['color'] as String);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'name': instance.name,
  'color': instance.color,
};
