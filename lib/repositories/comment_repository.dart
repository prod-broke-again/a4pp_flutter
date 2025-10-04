import 'package:dio/dio.dart';
import 'package:mobile/services/api_client.dart';

class CommentRepository {
  final ApiClient _apiClient;

  CommentRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Получить комментарии объекта по типу и слагу
  Future<Map<String, dynamic>> getComments(String type, String slug, {int page = 1, int perPage = 15}) async {
    try {
      final response = await _apiClient.dio.get('/comments/$type/$slug', queryParameters: {
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

  /// Добавить комментарий к объекту
  Future<Map<String, dynamic>> addComment(String type, String slug, String content) async {
    try {
      final response = await _apiClient.dio.post('/comments/$type/$slug', data: {
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

  /// Ответить на комментарий
  Future<Map<String, dynamic>> replyToComment(String type, String slug, int commentId, String content) async {
    try {
      final response = await _apiClient.dio.post('/comments/$type/$slug/$commentId/replies', data: {
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

  /// Поставить лайк комментарию
  Future<Map<String, dynamic>> likeComment(int commentId) async {
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

  /// Получить статус лайков комментария
  Future<Map<String, dynamic>> getCommentLikeStatus(int commentId) async {
    try {
      final response = await _apiClient.dio.get('/comments/$commentId/like-status');
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
}
