import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/profile_response.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/models/subscription.dart';
import 'package:mobile/models/transaction.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/preload_service.dart';
import '../../widgets/app_drawer.dart';
import '../home/home_digest_screen.dart';
import '../video_library/video_library_screen.dart';
import '../settings/settings_screen.dart';
import '../subscription/subscription_screen.dart';
import '../favorites/favorites_screen.dart';
import '../transactions/transactions_screen.dart';

class MainScreen extends StatefulWidget {
  final PreloadedData? preloadedData;

  const MainScreen({super.key, this.preloadedData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  User? _user;
  SubscriptionStatus? _subscriptionStatus;
  List<Product> _products = const [];
  List<Map<String, dynamic>> _notifications = const [];
  int _unreadNotificationsCount = 0;
  bool _isLoading = true;
  String? _error;

  // Last opened section persistence
  static const String _prefsKeyLastSection = 'main_last_section_index';
  int _selectedIndex = 0; // 0: HomeDigest, 1: Video (default fallback)

  @override
  void initState() {
    super.initState();
    _initializeWithPreloadedData();
    _loadLastSection();
  }

  /// Инициализация с предварительно загруженными данными или загрузка с API
  void _initializeWithPreloadedData() {
    if (widget.preloadedData != null && widget.preloadedData!.isComplete && !widget.preloadedData!.isExpired) {
      print('✅ Используем предварительно загруженные данные');
      _initializeFromPreloadedData(widget.preloadedData!);
    } else {
      print('🔄 Предзагруженные данные недоступны или устарели, загружаем с API');
      _loadProfile();
    }
  }

  /// Инициализация состояния из предварительно загруженных данных
  void _initializeFromPreloadedData(PreloadedData data) {
    try {
      // Парсим профиль
      final profileData = data.profileData!;
      _user = profileData.user;
      _products = profileData.products ?? [];
      _unreadNotificationsCount = profileData.unreadNotificationsCount;

      // Парсим текущую подписку
      final subscriptionData = data.subscriptionData!;
      final subscription = subscriptionData['subscription'];
      _subscriptionStatus = SubscriptionStatus(
        subscription: subscription != null ? Subscription.fromJson(subscription) : null,
        product: subscription != null && subscription['product'] != null
            ? Product.fromJson(subscription['product'])
            : null,
        isActive: subscription != null && subscription['status'] == 'active',
        auto: subscription != null ? subscription['auto_renew'] ?? false : false,
        expiresAt: subscription != null && subscription['expires_at'] != null
            ? DateTime.parse(subscription['expires_at'])
            : null,
      );

      // Парсим избранное
      final favoritesData = data.favoritesData!;
      final favorites = _safeGetList(favoritesData, 'favorites');
      // Здесь можно инициализировать избранное, если нужно

      // Парсим уведомления
      final notificationsData = data.notificationsData!;
      _notifications = _safeGetList(notificationsData, 'notifications')
          .cast<Map<String, dynamic>>();

      setState(() {
        _isLoading = false;
      });

      print('✅ Данные успешно инициализированы из предзагрузки');

    } catch (e) {
      print('❌ Ошибка инициализации предзагруженных данных: $e');
      // В случае ошибки переходим к обычной загрузке
      _loadProfile();
    }
  }

  /// Обновление счетчика непрочитанных уведомлений
  void _updateUnreadNotificationsCount(int count) {
    setState(() {
      _unreadNotificationsCount = count;
    });
  }

  /// Безопасное получение массива из данных API
  List<dynamic> _safeGetList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is List<dynamic>) {
      return value;
    }
    print('⚠️ MainScreen: ожидался массив для ключа "$key", но получен: ${value.runtimeType}');
    return [];
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await _authService.getProfile();
      // Видео категории теперь грузятся только при переходе на вкладку видео

      setState(() {
        _user = profile.user;
        _subscriptionStatus = profile.subscriptionStatus;
        _products = profile.products;
        _notifications = profile.notifications;
        _unreadNotificationsCount = profile.unreadNotificationsCount;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Ошибка загрузки профиля: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLastSection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_prefsKeyLastSection);
      if (saved != null && saved >= 0 && saved <= 5) {
        setState(() {
          _selectedIndex = saved;
        });
      }
    } catch (_) {
      // ignore errors silently
    }
  }

  Future<void> _saveLastSection(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKeyLastSection, index);
    } catch (_) {}
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
        title: Text(
          _selectedIndex == 0 ? 'Главная' : _selectedIndex == 1 ? 'Видео' : 'АЧПП',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      drawer: AppDrawer(
        user: _user,
        subscriptionStatus: _subscriptionStatus,
        products: _products,
        notifications: _notifications,
        unreadNotificationsCount: _unreadNotificationsCount,
        currentIndex: 1, // Видеотека по умолчанию
        onIndexChanged: (index) {
          // Обработка переключения между основными экранами
          switch (index) {
            case 0:
              // Домашний дайджест
              setState(() {
                _selectedIndex = 0;
              });
              _saveLastSection(0);
              Navigator.pop(context);
              break;
            case 1:
              // Видеотека
              setState(() {
                _selectedIndex = 1;
              });
              _saveLastSection(1);
              Navigator.pop(context);
              break;
            case 2:
              // Переход в профиль
              final profileUser = _user ?? User(
                id: 0,
                email: '',
                balance: 0,
                auto: false,
                psyLance: false,
                role: Role(name: '', color: ''),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    user: profileUser,
                    subscriptionStatus: _subscriptionStatus,
                    products: _products,
                  ),
                ),
              );
              _saveLastSection(2);
              break;
          }
        },
        onUnreadCountChanged: _updateUnreadNotificationsCount,
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
                          'Ошибка загрузки данных.\n\nПроверьте подключение к интернету и попробуйте снова.',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _loadProfile,
                          child: const Text('Повторить'),
                        )
                      ],
                    ),
                  ),
                )
              : _selectedIndex == 0
                  ? HomeDigestScreen(
                      user: _user,
                      subscription: _subscriptionStatus?.subscription,
                      products: _products,
                      preloadedData: widget.preloadedData,
                    )
                  : const VideoLibraryScreen(
                      showAppBar: false,
                    ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final User user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;

  const ProfileScreen({
    super.key,
    required this.user,
    this.subscriptionStatus,
    this.products = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок профиля
              Row(
                children: [
                                      CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF6B46C1),
                      child: Text(
                        user.fullName.isNotEmpty && (user.lastname?.isNotEmpty ?? false)
                            ? '${user.fullName[0]}${user.lastname![0]}'
                            : user.fullName.isNotEmpty 
                                ? user.fullName[0].toUpperCase()
                                : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.bio ?? 'Пользователь',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B46C1).withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF6B46C1).withAlpha(128),
                            ),
                          ),
                          child: Text(
                            user.role.name,
                            style: const TextStyle(
                              color: Color(0xFF6B46C1),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Баланс
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6B46C1),
                      Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B46C1).withAlpha(102),
                      spreadRadius: 4,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Баланс',
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.formattedBalance ?? '₽ ${user.balance.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                final uri = await AuthService().topupBalance(
                                  amount: 1000, // TODO: заменить на ввод суммы
                                );
                                // ignore: use_build_context_synchronously
                                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Не удалось открыть страницу оплаты')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6B46C1),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Пополнить',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              try {
                                final data = await AuthService().getTransactions(page: 1, perPage: 50);
                                final txs = (data['transactions'] as List<dynamic>? ?? [])
                                    .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
                                    .toList();
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransactionsScreen(
                                      transactions: txs,
                                      currentBalance: user.balance.toDouble(),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Транзакции',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Текущая подписка
              if (subscriptionStatus != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B46C1).withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.star, color: Color(0xFF6B46C1)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscriptionStatus!.productName ?? subscriptionStatus!.product?.name ?? 'Подписка',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Builder(
                              builder: (_) {
                                final expires = subscriptionStatus!.expiresAt;
                                String subtitle;
                                if (expires != null) {
                                  final now = DateTime.now();
                                  final diffDays = expires.difference(now).inDays;
                                  final safeDays = diffDays >= 0 ? diffDays : 0;
                                  final formatted = DateFormat('dd.MM.yyyy').format(expires);
                                  if (diffDays >= 0) {
                                    subtitle = 'До $formatted • осталось $safeDays ${pluralDaysRu(safeDays)}';
                                  } else {
                                    subtitle = 'Истекла $formatted';
                                  }
                                } else {
                                  subtitle = subscriptionStatus!.isActive ? 'Подписка активна' : 'Подписка не активна';
                                }
                                return Text(
                                  subtitle,
                                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Меню профиля
              const Text(
                'Настройки',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildMenuItem(
                icon: Icons.subscriptions,
                title: 'Подписка',
                subtitle: 'Управление тарифом',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        final current = subscriptionStatus?.subscription;
                        final available = products;
                        return SubscriptionScreen(
                          currentSubscription: current ??
                              Subscription(
                                id: 0,
                                productId: subscriptionStatus?.product?.id ?? 0,
                                userId: user.id,
                                status: subscriptionStatus?.isActive == true ? 'active' : 'none',
                                startsAt: DateTime.now(),
                                expiresAt: subscriptionStatus?.expiresAt ?? DateTime.now(),
                                amount: 0,
                                currency: 'RUB',
                                autoRenew: subscriptionStatus?.auto ?? false,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                product: subscriptionStatus?.product,
                              ),
                          availablePlans: available,
                          user: user,
                          subscriptionStatus: subscriptionStatus,
                          products: products,
                        );
                      },
                    ),
                  );
                },
              ),
              
              _buildMenuItem(
                icon: Icons.favorite,
                title: 'Мои избранные',
                subtitle: 'Клубы, курсы и встречи',
                onTap: () async {
                  try {
                    final data = await AuthService().getFavorites();
                    final favorites = (data['favorites'] as List<dynamic>? ?? [])
                        .map((f) => f as Map<String, dynamic>)
                        .toList();
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoritesScreen(
                          favorites: favorites,
                          user: user,
                          subscriptionStatus: subscriptionStatus,
                          products: products,
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
              ),
              
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Настройки',
                subtitle: 'Профиль и безопасность',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        user: user,
                        subscriptionStatus: subscriptionStatus,
                        products: products,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF6B46C1).withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6B46C1),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[600],
          size: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
      ),
    );
  }
}

String pluralDaysRu(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return 'день';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'дня';
  return 'дней';
}
