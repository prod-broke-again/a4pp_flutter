import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/models/profile_response.dart';
import 'package:mobile/models/notification.dart' as notification_model;
import 'package:mobile/services/notification_service.dart';
import '../../widgets/app_drawer.dart';

class NotificationsScreen extends StatefulWidget {
  final User? user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;
  final List<Map<String, dynamic>>? initialNotifications;
  final int? initialUnreadCount;

  const NotificationsScreen({
    super.key,
    this.user,
    this.subscriptionStatus,
    this.products = const [],
    this.initialNotifications,
    this.initialUnreadCount,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final NotificationService _notificationService = NotificationService();
  List<notification_model.Notification> _notifications = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _pagination;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Сначала пробуем использовать переданные уведомления из профиля
    if (widget.initialNotifications != null && widget.initialNotifications!.isNotEmpty) {
      setState(() {
        _notifications = widget.initialNotifications!
            .map((json) => notification_model.Notification.fromJson(json))
            .toList();
        _isLoading = false;
      });
      return;
    }

    // Если уведомлений в профиле нет, пробуем API
    try {
      final result = await _notificationService.getNotifications();
      setState(() {
        _notifications = result.notifications;
        _pagination = result.pagination;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Ошибка загрузки уведомлений через API: $e');
      // Если API не работает, показываем пустой список без ошибки
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      if (mounted) {
        setState(() {
          _notifications = _notifications.map<notification_model.Notification>((notification) {
            if (notification.id == notificationId) {
              return notification.copyWith(readAt: DateTime.now());
            }
            return notification;
          }).toList();
        });
      }
    } catch (e) {
      print('❌ Ошибка отметки уведомления как прочитанного: $e');
      // Отображаем уведомление об ошибке пользователю
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Не удалось отметить уведомление как прочитанное'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      if (mounted) {
        setState(() {
          _notifications = _notifications.map<notification_model.Notification>((notification) {
            return notification.copyWith(readAt: DateTime.now());
          }).toList();
        });
      }
    } catch (e) {
      print('❌ Ошибка отметки всех уведомлений как прочитанных: $e');
      // Отображаем уведомление об ошибке пользователю
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Не удалось отметить все уведомления как прочитанные'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getNotificationIcon(String type) {
    // Обрабатываем полные типы из Laravel (App\Notifications\...)
    if (type.contains('NewComment')) {
      return Icons.comment;
    } else if (type.contains('NewPost') || type.contains('Article')) {
      return Icons.article;
    } else if (type.contains('Meeting') || type.contains('Event')) {
      return Icons.event;
    } else if (type.contains('Subscription')) {
      return Icons.subscriptions;
    } else if (type.contains('Payment') || type.contains('Transaction')) {
      return Icons.payment;
    } else if (type.contains('Welcome') || type.contains('Welcome')) {
      return Icons.waving_hand;
    } else if (type.contains('Video') || type.contains('Content')) {
      return Icons.video_library;
    }

    // Старые типы для обратной совместимости
    switch (type) {
      case 'welcome':
        return Icons.waving_hand;
      case 'content':
        return Icons.video_library;
      case 'meeting':
        return Icons.event;
      case 'subscription':
        return Icons.subscriptions;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    // Обрабатываем полные типы из Laravel (App\Notifications\...)
    if (type.contains('NewComment')) {
      return const Color(0xFF3B82F6); // Синий для комментариев
    } else if (type.contains('NewPost') || type.contains('Article')) {
      return const Color(0xFF10B981); // Зеленый для статей
    } else if (type.contains('Meeting') || type.contains('Event')) {
      return const Color(0xFF8B5CF6); // Фиолетовый для встреч
    } else if (type.contains('Subscription')) {
      return const Color(0xFFF59E0B); // Желтый для подписок
    } else if (type.contains('Payment') || type.contains('Transaction')) {
      return const Color(0xFFEF4444); // Красный для платежей
    } else if (type.contains('Welcome')) {
      return const Color(0xFF10B981); // Зеленый для приветствий
    } else if (type.contains('Video') || type.contains('Content')) {
      return const Color(0xFF3B82F6); // Синий для контента
    }

    // Старые типы для обратной совместимости
    switch (type) {
      case 'welcome':
        return const Color(0xFF10B981);
      case 'content':
        return const Color(0xFF3B82F6);
      case 'meeting':
        return const Color(0xFF8B5CF6);
      case 'subscription':
        return const Color(0xFFF59E0B);
      case 'payment':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'Только что';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Уведомления',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              onPressed: _markAllAsRead,
              tooltip: 'Отметить все как прочитанные',
            ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      drawer: AppDrawer(
        user: widget.user,
        subscriptionStatus: widget.subscriptionStatus,
        products: widget.products,
        currentIndex: 0,
        onIndexChanged: (_) {},
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Ошибка загрузки уведомлений.\n\nПроверьте подключение к интернету и попробуйте снова.',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _loadNotifications,
                          child: const Text('Повторить'),
                        )
                      ],
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withAlpha(51),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.notifications_none,
                                color: Color(0xFF8B5CF6),
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              '📱 Уведомления',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'У вас пока нет уведомлений.\nНовые уведомления будут появляться здесь.',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Статистика
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D2D2D),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${_notifications.where((n) => !n.isRead).length}',
                                        style: const TextStyle(
                                          color: Color(0xFF8B5CF6),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Непрочитанных',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D2D2D),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${_notifications.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Всего',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Список уведомлений
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              final isRead = notification.isRead;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isRead ? const Color(0xFF2D2D2D) : const Color(0xFF3D3D3D),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isRead ? null : Border.all(
                                    color: const Color(0xFF8B5CF6).withAlpha(51),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getNotificationColor(notification.type).withAlpha(51),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getNotificationIcon(notification.type),
                                      color: _getNotificationColor(notification.type),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    notification.message,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      if (notification.userName != null)
                                        Text(
                                          'От: ${notification.userName}',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatDateTime(notification.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: isRead
                                      ? null
                                      : Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF8B5CF6),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                  onTap: () {
                                    if (!isRead) {
                                      _markAsRead(notification.id);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
