import 'package:mobile/models/category.dart';
import 'package:mobile/models/user.dart';

class Blog {
  final int id;
  final String title;
  final String slug;
  final String content;
  final String excerpt;
  final String? thumbnail;
  final String status;
  final String statusLabel;
  final Category? category;
  final User? author;
  final DateTime? publishedAt;
  final String? metaTitle;
  final String? metaDescription;
  final int viewsCount;
  final int likesCount;
  final int dislikesCount;
  final bool isLiked;
  final bool isDisliked;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Blog({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.excerpt,
    this.thumbnail,
    required this.status,
    required this.statusLabel,
    this.category,
    this.author,
    this.publishedAt,
    this.metaTitle,
    this.metaDescription,
    required this.viewsCount,
    required this.likesCount,
    required this.dislikesCount,
    required this.isLiked,
    required this.isDisliked,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    try {
      // Обработка разных форматов (блог vs новости)
      final status = json['status']?.toString() ?? json['type']?.toString() ?? 'published';
      final statusLabel = json['status_label']?.toString() ?? json['type_label']?.toString() ?? 'Опубликовано';

      // Формирование полного URL для thumbnail
      final rawThumbnail = json['thumbnail']?.toString() ?? json['thumbnail_url']?.toString() ?? json['image_url']?.toString();
      final thumbnail = rawThumbnail != null && !rawThumbnail.startsWith('http')
          ? 'https://appp-psy.ru$rawThumbnail'
          : rawThumbnail;

      return Blog(
        id: json['id'] as int? ?? 0,
        title: json['title']?.toString() ?? 'Без заголовка',
        slug: json['slug']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        excerpt: json['excerpt']?.toString() ?? '',
        thumbnail: thumbnail,
        status: status,
        statusLabel: statusLabel,
        category: json['category'] != null ? Category.fromJson(json['category']) : null,
        author: json['author'] != null ? User.fromJson(json['author']) : null,
        publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at'].toString()) : null,
        metaTitle: json['meta_title']?.toString(),
        metaDescription: json['meta_description']?.toString(),
        viewsCount: json['views_count'] as int? ?? 0,
        likesCount: json['likes_count'] as int? ?? 0,
        dislikesCount: json['dislikes_count'] as int? ?? 0,
        isLiked: json['is_liked'] as bool? ?? false,
        isDisliked: json['is_disliked'] as bool? ?? false,
        commentsCount: json['comments_count'] as int? ?? 0,
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
        updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
      );
    } catch (e) {
      print('Ошибка в Blog.fromJson: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}
