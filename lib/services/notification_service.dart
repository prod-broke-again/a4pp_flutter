import 'package:mobile/models/notification.dart';
import 'package:mobile/repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;

  NotificationService({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  /// Получить список уведомлений с пагинацией
  Future<({
    List<Notification> notifications,
    Map<String, dynamic> pagination,
    int unreadCount,
  })> getNotifications({
    int page = 1,
    int perPage = 15,
    bool unreadOnly = false,
  }) async {
    final data = await _repository.getNotifications(
      page: page,
      perPage: perPage,
      unreadOnly: unreadOnly,
    );

    final notificationsData = data['notifications'] as Map<String, dynamic>;
    final rawNotifications = notificationsData['data'] as List<dynamic>? ?? [];

    final notifications = rawNotifications
        .map((json) {
          try {
            return Notification.fromJson(json);
          } catch (e) {
            print('Ошибка парсинга уведомления: $e');
            print('JSON уведомления: $json');
            rethrow;
          }
        })
        .toList();

    final pagination = Map<String, dynamic>.from(notificationsData);
    final unreadCount = data['unread_count'] as int? ?? 0;

    return (
      notifications: notifications,
      pagination: pagination,
      unreadCount: unreadCount,
    );
  }

  /// Отметить уведомление как прочитанное
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final data = await _repository.markAsRead(notificationId);
    return data;
  }

  /// Отметить все уведомления как прочитанные
  Future<Map<String, dynamic>> markAllAsRead() async {
    final data = await _repository.markAllAsRead();
    return data;
  }

  /// Удалить уведомление
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    final data = await _repository.deleteNotification(notificationId);
    return data;
  }

  /// Очистить все уведомления
  Future<Map<String, dynamic>> clearAllNotifications() async {
    final data = await _repository.clearAllNotifications();
    return data;
  }
}
