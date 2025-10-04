import 'package:dio/dio.dart';
import 'package:mobile/services/api_client.dart';

class NewsRepository {
  final ApiClient _apiClient;

  NewsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Получить рекомендуемые новости для домашнего экрана: GET /news
  Future<Map<String, dynamic>> getFeaturedNews({int limit = 1}) async {
    try {
      final response = await _apiClient.dio.get('/news', queryParameters: {
        'featured': true,
        'per_page': limit,
        'sort': 'published_at',
        'order': 'desc',
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить рекомендуемые новости');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить список новостей: GET /news
  Future<Map<String, dynamic>> getNews({
    int page = 1,
    int perPage = 15,
    String? search,
    String? category,
    String? status,
    String? sort,
    String? order,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (category != null && category.isNotEmpty) query['category'] = category;
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (sort != null && sort.isNotEmpty) query['sort'] = sort;
      if (order != null && order.isNotEmpty) query['order'] = order;

      final response = await _apiClient.dio.get('/news', queryParameters: query);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить новости');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить новость по слагу: GET /news/{slug}
  Future<Map<String, dynamic>> getNewsItem(String slug) async {
    try {
      final response = await _apiClient.dio.get('/news/$slug');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить новость');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Поставить лайк новости: POST /news/{slug}/like
  Future<Map<String, dynamic>> likeNews(String slug) async {
    try {
      final response = await _apiClient.dio.post('/news/$slug/like');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось поставить лайк');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Поставить дизлайк новости: POST /news/{slug}/dislike
  Future<Map<String, dynamic>> dislikeNews(String slug) async {
    try {
      final response = await _apiClient.dio.post('/news/$slug/dislike');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось поставить дизлайк');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить статус лайков новости: GET /likes/status
  Future<Map<String, dynamic>> getNewsLikeStatus(int newsId) async {
    try {
      final response = await _apiClient.dio.get('/likes/status', queryParameters: {
        'likeable_id': newsId,
        'likeable_type': 'App\\Models\\News',
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось получить статус лайков');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить комментарии к новости: GET /comments/news/{slug}
  Future<Map<String, dynamic>> getNewsComments(String slug, {int page = 1, int perPage = 15}) async {
    try {
      final response = await _apiClient.dio.get('/comments/news/$slug', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить комментарии');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Добавить комментарий к новости: POST /comments/news/{slug}
  Future<Map<String, dynamic>> addNewsComment(String slug, String content) async {
    try {
      final response = await _apiClient.dio.post('/comments/news/$slug', data: {
        'content': content,
      });
      if (response.statusCode == 201 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось добавить комментарий');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Ответить на комментарий: POST /comments/news/{slug}/{commentId}/replies
  Future<Map<String, dynamic>> replyToNewsComment(String slug, int commentId, String content) async {
    try {
      final response = await _apiClient.dio.post('/comments/news/$slug/$commentId/replies', data: {
        'content': content,
      });
      if (response.statusCode == 201 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось ответить на комментарий');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Лайк комментария: POST /comments/{commentId}/like
  Future<Map<String, dynamic>> toggleCommentLike(int commentId) async {
    try {
      final response = await _apiClient.dio.post('/comments/$commentId/like');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось поставить лайк комментарию');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }
}
