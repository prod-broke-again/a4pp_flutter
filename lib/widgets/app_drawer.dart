import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/subscription.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/models/profile_response.dart';
import 'package:mobile/services/auth_service.dart';
import '../screens/courses/courses_screen.dart';
import '../screens/clubs/clubs_screen.dart';
import '../screens/meetings/meetings_screen.dart';
import '../screens/video_library/video_library_screen.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/blog/blog_screen.dart';
import '../screens/news/news_screen.dart';
import '../screens/news/news_detail_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppDrawer extends StatefulWidget {
  final User? user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;
  final List<Map<String, dynamic>> notifications;
  final int unreadNotificationsCount;
  final int currentIndex;
  final Function(int) onIndexChanged;

  const AppDrawer({
    super.key,
    required this.user,
    this.subscriptionStatus,
    this.products = const [],
    this.notifications = const [],
    this.unreadNotificationsCount = 0,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    print('🔍 AppDrawer.build: user = ${widget.user?.email ?? 'null'}');
    return Drawer(
      backgroundColor: const Color(0xFF2D2D2D),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header с информацией о пользователе
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название приложения
                const Text(
                  'АЧПП',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Профиль пользователя
                if (widget.user != null) ...[
                  Row(
                    children: [
                      // Аватар
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF6B46C1),
                        backgroundImage: widget.user!.avatar != null && widget.user!.avatar!.isNotEmpty
                            ? NetworkImage(widget.user!.avatar!)
                            : null,
                        child: widget.user!.avatar == null || widget.user!.avatar!.isEmpty
                            ? Text(
                                widget.user!.fullName.isNotEmpty
                                    ? widget.user!.fullName[0].toUpperCase()
                                    : widget.user!.email[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Информация о пользователе
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Имя и фамилия
                            Text(
                              widget.user!.fullName.isNotEmpty ? widget.user!.fullName : 'Пользователь',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Email
                            Text(
                              widget.user!.email,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Баланс
                            Text(
                              widget.user!.formattedBalance ?? '₽ ${widget.user!.balance.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Кнопки действий
                      Column(
                        children: [
                          // Кнопка настроек
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.grey),
                            iconSize: 20,
                            onPressed: () {
                              Navigator.pop(context);
                              if (widget.user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingsScreen(
                                      user: widget.user!,
                                      subscriptionStatus: widget.subscriptionStatus,
                                      products: widget.products,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),

                          // Кнопка смены темы (пока заглушка)
                          IconButton(
                            icon: const Icon(Icons.brightness_6, color: Colors.grey),
                            iconSize: 20,
                            onPressed: () {
                              Navigator.pop(context);
                              // Смена темы пока не реализована, просто закрываем drawer
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Кнопка "Перейти в профиль"
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Переходим в профиль
                        if (widget.user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                user: widget.user!,
                                subscriptionStatus: widget.subscriptionStatus,
                                products: widget.products,
                              ),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1).withAlpha(51),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        'Перейти в профиль',
                        style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Заглушка при загрузке
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ],
            ),
          ),

          // 🔴 Самое важное для пользователя (личное)
          _buildDrawerItem(
            context,
            icon: Icons.notifications,
            title: 'Уведомления',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(
                    user: widget.user,
                    subscriptionStatus: widget.subscriptionStatus,
                    products: widget.products,
                    initialNotifications: widget.notifications,
                    initialUnreadCount: widget.unreadNotificationsCount,
                  ),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.favorite,
            title: 'Избранное',
            onTap: () async {
              Navigator.pop(context);
              // Сначала переходим на экран с пустым списком, затем грузим данные там
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                    favorites: const [],
                    user: widget.user,
                    subscriptionStatus: widget.subscriptionStatus,
                    products: widget.products,
                  ),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.subscriptions,
            title: 'Подписка',
            onTap: () {
              Navigator.pop(context);
              if (widget.user != null && widget.subscriptionStatus != null) {
                final current = widget.subscriptionStatus!.subscription;
                final available = widget.products;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionScreen(
                      currentSubscription: current ??
                          Subscription(
                            id: 0,
                            productId: widget.subscriptionStatus!.product?.id ?? 0,
                            userId: widget.user!.id,
                            status: widget.subscriptionStatus!.isActive == true ? 'active' : 'none',
                            startsAt: DateTime.now(),
                            expiresAt: widget.subscriptionStatus!.expiresAt ?? DateTime.now(),
                            amount: 0,
                            currency: 'RUB',
                            autoRenew: widget.subscriptionStatus!.auto ?? false,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                            product: widget.subscriptionStatus!.product,
                          ),
                      availablePlans: available,
                      user: widget.user,
                      subscriptionStatus: widget.subscriptionStatus,
                      products: widget.products,
                    ),
                  ),
                );
              }
            },
          ),

          // 📚 Контент доступный по подписке
          _buildDrawerItem(
            context,
            icon: Icons.school,
            title: 'Курсы',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoursesScreen(
                    user: widget.user,
                    subscriptionStatus: widget.subscriptionStatus,
                    products: widget.products,
                  ),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.group,
            title: 'Клубы',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClubsScreen(
                    user: widget.user,
                    subscriptionStatus: widget.subscriptionStatus,
                    products: widget.products,
                  ),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.video_library,
            title: 'Видео',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VideoLibraryScreen()),
              );
            },
          ),

          // 🟢 Социальное и сообщество
          _buildDrawerItem(
            context,
            icon: Icons.event,
            title: 'Встречи',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MeetingsScreen(
                    user: widget.user,
                    subscriptionStatus: widget.subscriptionStatus,
                    products: widget.products,
                  ),
                ),
              );
            },
          ),

          // 📖 Свободный контент
                 _buildDrawerItem(
                   context,
                   icon: Icons.book,
                   title: 'Блог',
                   onTap: () {
                     Navigator.pop(context);
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (_) => BlogScreen(
                           user: widget.user,
                           subscriptionStatus: widget.subscriptionStatus,
                           products: widget.products,
                         ),
                       ),
                     );
                   },
                 ),

          // 🔵 Информация
                 _buildDrawerItem(
                   context,
                   icon: Icons.article,
                   title: 'Новости',
                   onTap: () {
                     Navigator.pop(context);
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (_) => NewsScreen(
                           user: widget.user,
                           subscriptionStatus: widget.subscriptionStatus,
                           products: widget.products,
                         ),
                       ),
                     );
                   },
                 ),

          // Разделитель
          const Divider(color: Colors.grey, height: 1),

          // Кнопка выхода
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Выйти',
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Выход из аккаунта',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Вы действительно хотите выйти из аккаунта?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Отмена',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Закрываем диалог
                Navigator.pop(context); // Закрываем drawer

                try {
                  await AuthService().logout();
                  // После выхода переходим на экран авторизации
                  Navigator.of(context).pushReplacementNamed('/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка при выходе: $e')),
                  );
                }
              },
              child: const Text(
                'Выйти',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
