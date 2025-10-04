import 'package:dio/dio.dart';
import 'package:mobile/services/api_client.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Получить список уведомлений: GET /api/notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 15,
    bool unreadOnly = false,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (unreadOnly) {
        query['unread_only'] = 'true';
      }

      final response = await _apiClient.dio.get('/notifications', queryParameters: query);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Не удалось загрузить уведомления');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Отметить уведомление как прочитанное: POST /api/notifications/{id}/read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.dio.post('/notifications/$notificationId/read');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Не удалось отметить уведомление как прочитанное');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Отметить все уведомления как прочитанные: POST /api/notifications/mark-all-read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.post('/notifications/mark-all-read');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Не удалось отметить все уведомления как прочитанные');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Удалить уведомление: DELETE /api/notifications/{id}
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      final response = await _apiClient.dio.delete('/notifications/$notificationId');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Не удалось удалить уведомление');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Очистить все уведомления: DELETE /api/notifications/clear-all
  Future<Map<String, dynamic>> clearAllNotifications() async {
    try {
      final response = await _apiClient.dio.delete('/notifications/clear-all');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Не удалось очистить все уведомления');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }
}
