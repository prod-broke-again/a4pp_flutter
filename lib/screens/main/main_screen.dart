import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/services/auth_service.dart';
import 'package:achpp/models/subscription.dart';
import 'package:achpp/models/transaction.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:achpp/services/preload_service.dart';
import '../../widgets/app_drawer.dart';
import '../home/home_digest_screen.dart';
import '../video_library/video_library_screen.dart';
import '../settings/settings_screen.dart';
import '../subscription/subscription_screen.dart';
import '../favorites/favorites_screen.dart';
import '../transactions/transactions_screen.dart';
import '../profile/profile_screen.dart';

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

  void _updateUser(User updatedUser) {
    setState(() {
      _user = updatedUser;
    });
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          _selectedIndex == 0 ? 'Главная' : _selectedIndex == 1 ? 'Видео' : 'АЧПП',
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
                    onUserUpdated: _updateUser,
                  ),
                ),
              );
              _saveLastSection(2);
              break;
          }
        },
        onUserUpdated: _updateUser,
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
                        Text(
                          'Ошибка загрузки данных.\n\nПроверьте подключение к интернету и попробуйте снова.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
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
