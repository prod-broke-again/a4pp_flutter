import 'package:mobile/models/blog.dart';
import 'package:mobile/models/comment.dart';
import 'package:mobile/repositories/blog_repository.dart';
import 'package:mobile/services/comment_service.dart';

class BlogService {
  final BlogRepository _repository;
  final CommentService _commentService;

  BlogService({BlogRepository? repository})
      : _repository = repository ?? BlogRepository(),
        _commentService = CommentService();

  /// Получить список статей блога с пагинацией и фильтрами
  Future<({
    List<Blog> posts,
    Map<String, dynamic> pagination,
  })> getBlogPosts({
    int page = 1,
    int perPage = 15,
    String? search,
    String? category,
    String? status,
    String? sort,
    String? order,
  }) async {
    final data = await _repository.getBlogPosts(
      page: page,
      perPage: perPage,
      search: search,
      category: category,
      status: status,
      sort: sort,
      order: order,
    );

    // Выводим ответ от API в консоль
    print('🔍 BLOG API Response: $data');

    final posts = (data['blogs'] as List<dynamic>? ?? [])
        .map((json) => Blog.fromJson(json))
        .toList();
    final pagination = Map<String, dynamic>.from(data['pagination'] as Map? ?? {});

    return (posts: posts, pagination: pagination);
  }

  /// Получить статью блога по слагу
  Future<Blog> getBlogPost(String slug) async {
    final data = await _repository.getBlogPost(slug);

    // Выводим ответ от API в консоль
    print('🔍 BLOG POST API Response: $data');

    return Blog.fromJson(data['post'] ?? data);
  }

  /// Лайк статьи
  Future<({
    bool isLiked,
    bool isDisliked,
    int likesCount,
    int dislikesCount,
  })> likeBlogPost(String slug) async {
    final data = await _repository.likeBlogPost(slug);
    return (
      isLiked: data['is_liked'] as bool? ?? false,
      isDisliked: data['is_disliked'] as bool? ?? false,
      likesCount: data['likes_count'] as int? ?? 0,
      dislikesCount: data['dislikes_count'] as int? ?? 0,
    );
  }

  /// Дизлайк статьи
  Future<({
    bool isLiked,
    bool isDisliked,
    int likesCount,
    int dislikesCount,
  })> dislikeBlogPost(String slug) async {
    final data = await _repository.dislikeBlogPost(slug);
    return (
      isLiked: data['is_liked'] as bool? ?? false,
      isDisliked: data['is_disliked'] as bool? ?? false,
      likesCount: data['likes_count'] as int? ?? 0,
      dislikesCount: data['dislikes_count'] as int? ?? 0,
    );
  }

  /// Получить комментарии статьи блога
  Future<({
    List<Comment> comments,
    Map<String, dynamic> pagination,
  })> getBlogComments(String slug, {int page = 1, int perPage = 15}) async {
    return _commentService.getComments('blogs', slug, page: page, perPage: perPage);
  }

  /// Добавить комментарий к статье блога
  Future<Comment> addBlogComment(String slug, String content) async {
    return _commentService.addComment('blogs', slug, content);
  }

  /// Ответить на комментарий в блоге
  Future<Comment> replyToBlogComment(String slug, int commentId, String content) async {
    return _commentService.replyToComment('blogs', slug, commentId, content);
  }

  /// Лайк комментария в блоге
  Future<Map<String, dynamic>> toggleBlogCommentLike(int commentId) async {
    return _commentService.toggleCommentLike(commentId);
  }
}
