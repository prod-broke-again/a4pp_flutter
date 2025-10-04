import 'package:mobile/models/user.dart';

class Comment {
  final int id;
  final String content;
  final String status;
  final User? user;
  final int likesCount;
  final bool isLiked;
  final List<Comment>? replies;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.status,
    this.user,
    required this.likesCount,
    required this.isLiked,
    this.replies,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      content: json['content'] as String,
      status: json['status'] as String,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((reply) => Comment.fromJson(reply)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
