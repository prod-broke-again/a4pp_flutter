import 'package:achpp/models/category.dart';
import 'package:achpp/models/course.dart';
import 'package:achpp/models/video_folder.dart';

class Video {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? videoUrl;
  final String? videoId;
  final String? thumbnailUrl;
  final int durationMinutes;
  final int actualDuration;
  final String formattedDuration;
  final int viewCount;
  final bool isFree;
  final bool canWatch;
  final VideoFolder? videoFolder;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? likesCount;
  final int? dislikesCount;
  final bool? isLikedByUser;
  final bool? isDislikedByUser;
  final String? status;
  final int? sortOrder;
  final List<String>? tags;
  final String? notes;
  final String? metaTitle;
  final String? metaDescription;

  Video({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.videoUrl,
    this.videoId,
    this.thumbnailUrl,
    required this.durationMinutes,
    required this.actualDuration,
    required this.formattedDuration,
    required this.viewCount,
    required this.isFree,
    required this.canWatch,
    this.videoFolder,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount,
    this.dislikesCount,
    this.isLikedByUser,
    this.isDislikedByUser,
    this.status,
    this.sortOrder,
    this.tags,
    this.notes,
    this.metaTitle,
    this.metaDescription,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String?,
      videoId: json['video_id'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      actualDuration: json['actual_duration'] as int? ?? 0,
      formattedDuration: json['formatted_duration'] as String? ?? '0 мин',
      viewCount: json['view_count'] as int? ?? 0,
      isFree: json['is_free'] as bool? ?? false,
      canWatch: json['can_watch'] as bool? ?? false,
      videoFolder: json['video_folder'] != null ? VideoFolder.fromJson(json['video_folder']) : null,
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
      likesCount: json['likes_count'] as int?,
      dislikesCount: json['dislikes_count'] as int?,
      isLikedByUser: json['is_liked_by_user'] as bool?,
      isDislikedByUser: json['is_disliked_by_user'] as bool?,
      status: json['status'] as String?,
      sortOrder: json['sort_order'] as int?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      notes: json['notes'] as String?,
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
    );
  }
}
