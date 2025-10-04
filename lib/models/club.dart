import 'package:mobile/models/user.dart';
import 'package:mobile/models/club_meeting.dart';

class Club {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final String? zoomLink;
  final String? materialsFolderUrl;
  final bool autoMaterials;
  final double currentDonations;
  final String formattedCurrentDonations;
  final String status;
  final int productLevel;
  final User? owner;
  final bool isFavoritedByUser;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ClubMeeting>? meetings;
  final List<ClubMeeting>? upcomingMeetings;
  final ClubMeeting? nextMeeting;
  final String? speakers;

  Club({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.image,
    this.zoomLink,
    this.materialsFolderUrl,
    required this.autoMaterials,
    required this.currentDonations,
    required this.formattedCurrentDonations,
    required this.status,
    required this.productLevel,
    this.owner,
    required this.isFavoritedByUser,
    required this.createdAt,
    required this.updatedAt,
    this.meetings,
    this.upcomingMeetings,
    this.nextMeeting,
    this.speakers,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Парсинг клуба с ID: ${json['id']}');

      final club = Club(
        id: json['id'] as int,
        name: json['name'] as String? ?? json['title'] as String? ?? 'Без названия',
        slug: json['slug'] as String? ?? '',
        description: json['description'] as String? ?? '',
        image: json['image'] as String?,
        zoomLink: json['zoom_link'] as String?,
        materialsFolderUrl: json['materials_folder_url'] as String?,
        autoMaterials: json['auto_materials'] as bool? ?? false,
        currentDonations: _parseDonations(json['current_donations']),
        formattedCurrentDonations: json['formatted_current_donations'] as String? ?? '0,00 ₽',
        status: json['status'] as String? ?? 'active',
        productLevel: json['product_level'] as int? ?? 1,
        owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
        isFavoritedByUser: json['is_favorited_by_user'] as bool? ?? false,
        createdAt: _tryParseDateTime(json['created_at']) ?? DateTime.now(),
        updatedAt: _tryParseDateTime(json['updated_at']) ?? DateTime.now(),
        meetings: json['meetings'] != null
            ? (json['meetings'] as List<dynamic>).map((m) => ClubMeeting.fromJson(m)).toList()
            : null,
        upcomingMeetings: json['upcoming_meetings'] != null
            ? (json['upcoming_meetings'] as List<dynamic>).map((m) => ClubMeeting.fromJson(m)).toList()
            : null,
        nextMeeting: json['next_meeting'] != null
            ? ClubMeeting.fromJson(json['next_meeting'])
            : null,
        speakers: json['speakers'] as String?,
      );

      print('✅ Клуб успешно распарсен: ${club.name}');
      return club;
    } catch (e, stackTrace) {
      print('❌ Ошибка парсинга клуба: $e');
      print('📄 Данные клуба: $json');
      print('🔍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  static DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) {
        return DateTime.parse(value);
      }
      return null;
    } catch (e) {
      print('❌ Ошибка парсинга даты: $e, значение: $value');
      return null;
    }
  }

  static double _parseDonations(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
