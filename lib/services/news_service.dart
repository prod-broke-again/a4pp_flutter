import 'package:achpp/models/news.dart';
import 'package:achpp/models/comment.dart';
import 'package:achpp/repositories/news_repository.dart';
import 'package:achpp/services/comment_service.dart';

class NewsService {
  final NewsRepository _repository;
  final CommentService _commentService;

  NewsService({NewsRepository? repository})
      : _repository = repository ?? NewsRepository(),
        _commentService = CommentService();

  /// Получить список новостей с пагинацией и фильтрами
  Future<({
    List<News> news,
    Map<String, dynamic> pagination,
  })> getNews({
    int page = 1,
    int perPage = 15,
    String? search,
    String? category,
    String? status,
    String? sort,
    String? order,
  }) async {
    final data = await _repository.getNews(
      page: page,
      perPage: perPage,
      search: search,
      category: category,
      status: status,
      sort: sort,
      order: order,
    );

    final news = (data['news'] as List<dynamic>? ?? [])
        .map((json) {
          try {
            return News.fromJson(json);
          } catch (e) {
            print('Ошибка парсинга новости: $e');
            print('JSON новости: $json');
            rethrow;
          }
        })
        .toList();
    final pagination = Map<String, dynamic>.from(data['pagination'] as Map? ?? {});

    return (news: news, pagination: pagination);
  }

  /// Получить новость по слагу
  Future<News> getNewsItem(String slug) async {
    final data = await _repository.getNewsItem(slug);
    return News.fromJson(data['news'] ?? data);
  }

  /// Поставить лайк новости
  Future<({
    bool isLiked,
    bool isDisliked,
    int likesCount,
    int dislikesCount,
  })> likeNews(String slug) async {
    final data = await _repository.likeNews(slug);
    return (
      isLiked: data['is_liked'] as bool? ?? false,
      isDisliked: data['is_disliked'] as bool? ?? false,
      likesCount: data['likes_count'] as int? ?? 0,
      dislikesCount: data['dislikes_count'] as int? ?? 0,
    );
  }

  /// Поставить дизлайк новости
  Future<({
    bool isLiked,
    bool isDisliked,
    int likesCount,
    int dislikesCount,
  })> dislikeNews(String slug) async {
    final data = await _repository.dislikeNews(slug);
    return (
      isLiked: data['is_liked'] as bool? ?? false,
      isDisliked: data['is_disliked'] as bool? ?? false,
      likesCount: data['likes_count'] as int? ?? 0,
      dislikesCount: data['dislikes_count'] as int? ?? 0,
    );
  }

  /// Получить статус лайков новости
  Future<({
    bool isLiked,
    bool isDisliked,
    int likesCount,
    int dislikesCount,
  })> getNewsLikeStatus(int newsId) async {
    final data = await _repository.getNewsLikeStatus(newsId);
    return (
      isLiked: data['is_liked'] as bool? ?? false,
      isDisliked: data['is_disliked'] as bool? ?? false,
      likesCount: data['likes_count'] as int? ?? 0,
      dislikesCount: data['dislikes_count'] as int? ?? 0,
    );
  }

  /// Получить комментарии к новости
  Future<({
    List<Comment> comments,
    Map<String, dynamic> pagination,
  })> getNewsComments(String slug, {int page = 1, int perPage = 15}) async {
    return _commentService.getComments('news', slug, page: page, perPage: perPage);
  }

  /// Добавить комментарий к новости
  Future<Comment> addNewsComment(String slug, String content) async {
    return _commentService.addComment('news', slug, content);
  }

  /// Ответить на комментарий в новости
  Future<Comment> replyToNewsComment(String slug, int commentId, String content) async {
    return _commentService.replyToComment('news', slug, commentId, content);
  }

  /// Лайк комментария в новости
  Future<Map<String, dynamic>> toggleCommentLike(int commentId) async {
    return _commentService.toggleCommentLike(commentId);
  }
}
