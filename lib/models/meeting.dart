import 'package:achpp/models/user.dart';
import 'package:achpp/models/category.dart';

class Meeting {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final String date;
  final String formattedDate;
  final String startTime;
  final String endTime;
  final String formattedStartTime;
  final String formattedEndTime;
  final String duration;
  final String format;
  final String formatLabel;
  final String? platform;
  final String? joinUrl;
  final String? location;
  final int maxParticipants;
  final String status;
  final String statusLabel;
  final String? notes;
  final User? organizer;
  final Category? category;
  final int participantsCount;
  final int commentsCount;
  final bool isUpcoming;
  final bool isPast;
  final bool isToday;
  final bool isOrganizer;
  final bool isFavoritedByUser;
  final int likesCount;
  final bool isLiked;
  final String? speakers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Meeting({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    required this.date,
    required this.formattedDate,
    required this.startTime,
    required this.endTime,
    required this.formattedStartTime,
    required this.formattedEndTime,
    required this.duration,
    required this.format,
    required this.formatLabel,
    this.platform,
    this.joinUrl,
    this.location,
    required this.maxParticipants,
    required this.status,
    required this.statusLabel,
    this.notes,
    this.organizer,
    this.category,
    required this.participantsCount,
    required this.commentsCount,
    required this.isUpcoming,
    required this.isPast,
    required this.isToday,
    required this.isOrganizer,
    required this.isFavoritedByUser,
    required this.likesCount,
    required this.isLiked,
    this.speakers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      date: json['date'] as String,
      formattedDate: json['formatted_date'] as String? ?? '',
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      formattedStartTime: json['formatted_start_time'] as String? ?? '',
      formattedEndTime: json['formatted_end_time'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      format: json['format'] as String? ?? '',
      formatLabel: json['format_label'] as String? ?? '',
      platform: json['platform'] as String?,
      joinUrl: json['join_url'] as String?,
      location: json['location'] as String?,
      maxParticipants: json['max_participants'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      notes: json['notes'] as String?,
      organizer: json['organizer'] != null ? User.fromJson(json['organizer']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      participantsCount: json['participants_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isUpcoming: json['is_upcoming'] as bool? ?? false,
      isPast: json['is_past'] as bool? ?? false,
      isToday: json['is_today'] as bool? ?? false,
      isOrganizer: json['is_organizer'] as bool? ?? false,
      isFavoritedByUser: json['is_favorited_by_user'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      speakers: json['speakers'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }
}
