import 'package:mobile/models/user.dart';

class News {
  final int id;
  final String title;
  final String slug;
  final String content;
  final String excerpt;
  final String? imageUrl;
  final String type;
  final String typeLabel;
  final String priority;
  final String priorityLabel;
  final String priorityColor;
  final bool isFeatured;
  final bool isPinned;
  final DateTime? publishedAt;
  final String? formattedPublishedAt;
  final User? author;
  final bool isOrganizationAuthor;
  final int likesCount;
  final int dislikesCount;
  final bool isLiked;
  final bool isDisliked;
  final int viewsCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  News({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.excerpt,
    this.imageUrl,
    required this.type,
    required this.typeLabel,
    required this.priority,
    required this.priorityLabel,
    required this.priorityColor,
    required this.isFeatured,
    required this.isPinned,
    this.publishedAt,
    this.formattedPublishedAt,
    this.author,
    required this.isOrganizationAuthor,
    required this.likesCount,
    required this.dislikesCount,
    required this.isLiked,
    required this.isDisliked,
    required this.viewsCount,
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String,
      imageUrl: json['image_url'] as String?,
      type: json['type'] as String,
      typeLabel: json['type_label'] as String,
      priority: json['priority'] as String,
      priorityLabel: json['priority_label'] as String,
      priorityColor: json['priority_color'] as String,
      isFeatured: json['is_featured'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at'] as String) : null,
      formattedPublishedAt: json['formatted_published_at'] as String?,
      author: json['author'] != null ? User.fromJson(json['author'] as Map<String, dynamic>) : null,
      isOrganizationAuthor: json['is_organization_author'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      dislikesCount: json['dislikes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isDisliked: json['is_disliked'] as bool? ?? false,
      viewsCount: json['views_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
