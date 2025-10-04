import 'video.dart';

class VideoFolder {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int? parentId;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? videosCount;
  final int? subcategoriesCount;
  final int? totalVideosCount;
  final List<VideoFolder>? subfolders;
  final List<Video>? videos;

  VideoFolder({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.videosCount,
    this.subcategoriesCount,
    this.totalVideosCount,
    this.subfolders,
    this.videos,
  });

  factory VideoFolder.fromJson(Map<String, dynamic> json) {
    return VideoFolder(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      parentId: json['parent_id'] as int?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
      videosCount: json['videos_count'] as int?,
      subcategoriesCount: json['subcategories_count'] as int?,
      totalVideosCount: json['total_videos_count'] as int?,
      // API v2 возвращает ключ "subcategories"; поддержим оба варианта для совместимости
      subfolders: (json['subcategories'] ?? json['subfolders']) != null
          ? ((json['subcategories'] ?? json['subfolders']) as List)
              .map((subfolder) => VideoFolder.fromJson(subfolder))
              .toList()
          : null,
      videos: json['videos'] != null
          ? (json['videos'] as List).map((video) => Video.fromJson(video)).toList()
          : null,
    );
  }
}
