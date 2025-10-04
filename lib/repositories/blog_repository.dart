import 'package:dio/dio.dart';
import 'package:mobile/services/api_client.dart';

class BlogRepository {
  final ApiClient _apiClient;

  BlogRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Получить список статей блога: GET /blog
  Future<Map<String, dynamic>> getBlogPosts({
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

      final response = await _apiClient.dio.get('/blog', queryParameters: query);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить статьи блога');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить статью блога по слагу: GET /blog/{slug}
  Future<Map<String, dynamic>> getBlogPost(String slug) async {
    try {
      final response = await _apiClient.dio.get('/blog/$slug');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить статью');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Лайк статьи: POST /blog/{slug}/like
  Future<Map<String, dynamic>> likeBlogPost(String slug) async {
    try {
      final response = await _apiClient.dio.post('/blog/$slug/like');
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

  /// Дизлайк статьи: POST /blog/{slug}/dislike
  Future<Map<String, dynamic>> dislikeBlogPost(String slug) async {
    try {
      final response = await _apiClient.dio.post('/blog/$slug/dislike');
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
}
