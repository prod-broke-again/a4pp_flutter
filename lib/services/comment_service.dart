import 'package:mobile/models/comment.dart';
import 'package:mobile/repositories/comment_repository.dart';

class CommentService {
  final CommentRepository _repository;

  CommentService({CommentRepository? repository})
      : _repository = repository ?? CommentRepository();

  /// Получить комментарии объекта по типу и слагу
  Future<({
    List<Comment> comments,
    Map<String, dynamic> pagination,
  })> getComments(String type, String slug, {int page = 1, int perPage = 15}) async {
    final data = await _repository.getComments(type, slug, page: page, perPage: perPage);
    final comments = (data['comments'] as List<dynamic>? ?? [])
        .map((json) => Comment.fromJson(json))
        .toList();
    final pagination = Map<String, dynamic>.from(data['pagination'] as Map? ?? {});

    return (comments: comments, pagination: pagination);
  }

  /// Добавить комментарий к объекту
  Future<Comment> addComment(String type, String slug, String content) async {
    final data = await _repository.addComment(type, slug, content);
    return Comment.fromJson(data['comment'] ?? data);
  }

  /// Ответить на комментарий
  Future<Comment> replyToComment(String type, String slug, int commentId, String content) async {
    final data = await _repository.replyToComment(type, slug, commentId, content);
    return Comment.fromJson(data['comment'] ?? data);
  }

  /// Поставить лайк комментарию
  Future<Map<String, dynamic>> toggleCommentLike(int commentId) async {
    final data = await _repository.likeComment(commentId);
    return data;
  }

  /// Получить статус лайков комментария
  Future<Map<String, dynamic>> getCommentLikeStatus(int commentId) async {
    final data = await _repository.getCommentLikeStatus(commentId);
    return data;
  }
}
