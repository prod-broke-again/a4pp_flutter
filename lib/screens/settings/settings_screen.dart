import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
import 'package:mobile/models/notification_preferences.dart';
import 'package:mobile/models/subscription.dart';
import 'package:mobile/models/profile_response.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/auth_service.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
import '../../widgets/app_drawer.dart';
import '../transactions/transactions_screen.dart';
import '../subscription/subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;

  const SettingsScreen({
    super.key,
    required this.user,
    this.subscriptionStatus,
    this.products = const [],
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late User _currentUser;
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();
  // Удалено: image picker больше не используется
  
  NotificationPreferences? _notificationPreferences;
  bool _preferencesLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadNotificationPreferences();
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
          'Настройки',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
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
        currentIndex: 0, // Не используется в настройках
        onIndexChanged: (_) {}, // Не используется в настройках
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Настройки уведомлений
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Уведомления',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (_preferencesLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_notificationPreferences != null) ...[
                  _buildNotificationSection(
                    title: 'Email уведомления',
                    icon: Icons.email,
                    preferences: _notificationPreferences!.email,
                    onPreferenceChanged: _updateEmailPreference,
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationSection(
                    title: 'Push уведомления',
                    icon: Icons.notifications,
                    preferences: _notificationPreferences!.database,
                    onPreferenceChanged: _updateDatabasePreference,
                  ),
                ] else
                  _buildMenuTile(
                    icon: Icons.refresh,
                    title: 'Загрузить предпочтения',
                    subtitle: 'Попробовать снова',
                    onTap: _loadNotificationPreferences,
                  ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Тема
            _buildSection(
              title: 'Тема',
              children: [
                _buildMenuTile(
                  icon: Icons.brightness_6,
                  title: 'Смена темы',
                  subtitle: 'Светлая / темная (в разработке)',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Смена темы в разработке')),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF6B46C1),
            child: _currentUser.avatar != null 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      _currentUser.avatar!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    _currentUser.fullName.isNotEmpty ? _currentUser.fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser.email,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _currentUser.role.name,
                    style: const TextStyle(
                      color: Color(0xFF6B46C1),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editProfile(),
            icon: const Icon(
              Icons.edit,
              color: Color(0xFF6B46C1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF6B46C1).withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF6B46C1), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6B46C1),
        activeTrackColor: const Color(0xFF6B46C1).withAlpha(77),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF6B46C1).withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF6B46C1), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
      ),
      trailing: onTap != null
          ? const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required IconData icon,
    required dynamic preferences,
    required Function(String key, bool value) onPreferenceChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6B46C1), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            icon: Icons.subscriptions,
            title: 'Подписки',
            subtitle: 'Уведомления о новых подписках',
            value: preferences.subscriptions,
            onChanged: (value) => onPreferenceChanged('subscriptions', value),
          ),
          _buildSwitchTile(
            icon: Icons.people,
            title: 'Социальные',
            subtitle: 'Уведомления о социальной активности',
            value: preferences.social,
            onChanged: (value) => onPreferenceChanged('social', value),
          ),
          _buildSwitchTile(
            icon: Icons.event,
            title: 'События',
            subtitle: 'Уведомления о предстоящих событиях',
            value: preferences.events,
            onChanged: (value) => onPreferenceChanged('events', value),
          ),
          _buildSwitchTile(
            icon: Icons.account_balance_wallet,
            title: 'Финансовые',
            subtitle: 'Уведомления о финансовых операциях',
            value: preferences.financial,
            onChanged: (value) => onPreferenceChanged('financial', value),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Выйти из аккаунта',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withAlpha(204),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => _ProfileEditDialog(
        user: _currentUser,
        apiClient: _apiClient,
        onAvatarChanged: _updateAvatar,
        onAvatarDeleted: _deleteAvatar,
        onUserUpdated: (updated) {
          setState(() {
            _currentUser = updated;
          });
        },
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(
        onPasswordChanged: _changePassword,
      ),
    );
  }

  void _showBalanceInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Баланс',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Текущий баланс: ${_currentUser.formattedBalance ?? '0,00 ₽'}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Баланс используется для оплаты подписок и донатов.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: Color(0xFF6B46C1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactions() {
    Navigator.pushNamed(context, '/transactions');
  }

  void _showTopUpDialog() {
    showDialog(
      context: context,
      builder: (context) => _TopUpDialog(
        onTopUp: _topUpBalance,
      ),
    );
  }

  void _showTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пользовательское соглашение'),
        backgroundColor: Color(0xFF6B46C1),
      ),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Политика конфиденциальности'),
        backgroundColor: Color(0xFF6B46C1),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Выход из аккаунта',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Вы уверены, что хотите выйти из аккаунта?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text(
              'Выйти',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      await _authService.logout();
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выходе: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    try {
      setState(() => _isLoading = true);
      
      await _apiClient.put('/profile/change-password', data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пароль успешно изменен'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при смене пароля: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _topUpBalance(double amount) async {
    try {
      setState(() => _isLoading = true);
      
      final response = await _apiClient.post('/balance/topup', data: {
        'amount': amount,
        'success_url': 'https://appp-psy.ru/success',
        'fail_url': 'https://appp-psy.ru/fail',
      });

      if (mounted) {
        // Здесь можно открыть URL для оплаты
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Перенаправление на страницу оплаты...'),
            backgroundColor: Color(0xFF6B46C1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при пополнении баланса: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateAvatar(String avatarUrl) async {
    setState(() {
      _currentUser = User(
        id: _currentUser.id,
        firstname: _currentUser.firstname,
        lastname: _currentUser.lastname,
        email: _currentUser.email,
        phone: _currentUser.phone,
        bio: _currentUser.bio,
        avatar: avatarUrl,
        balance: _currentUser.balance,
        formattedBalance: _currentUser.formattedBalance,
        emailVerifiedAt: _currentUser.emailVerifiedAt,
        auto: _currentUser.auto,
        psyLance: _currentUser.psyLance,
        role: _currentUser.role,
        createdAt: _currentUser.createdAt,
        updatedAt: _currentUser.updatedAt,
      );
    });
  }

  Future<void> _deleteAvatar() async {
    try {
      setState(() => _isLoading = true);
      
      await _apiClient.delete('/profile/avatar');

      if (mounted) {
        setState(() {
          _currentUser = User(
            id: _currentUser.id,
            firstname: _currentUser.firstname,
            lastname: _currentUser.lastname,
            email: _currentUser.email,
            phone: _currentUser.phone,
            bio: _currentUser.bio,
            avatar: null,
            balance: _currentUser.balance,
            formattedBalance: _currentUser.formattedBalance,
            emailVerifiedAt: _currentUser.emailVerifiedAt,
            auto: _currentUser.auto,
            psyLance: _currentUser.psyLance,
            role: _currentUser.role,
            createdAt: _currentUser.createdAt,
            updatedAt: _currentUser.updatedAt,
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Аватар успешно удален'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении аватара: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Методы для работы с настройками уведомлений
  Future<void> _loadNotificationPreferences() async {
    try {
      setState(() => _preferencesLoading = true);
      
      final response = await _apiClient.get('/preferences');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          setState(() {
            _notificationPreferences = NotificationPreferences.fromJson(data['data']['preferences']);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки настроек: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _preferencesLoading = false);
      }
    }
  }

  Future<void> _updateEmailPreference(String key, bool value) async {
    if (_notificationPreferences == null) return;
    
    try {
      final currentEmail = _notificationPreferences!.email;
      EmailPreferences newEmailPrefs;

      switch (key) {
        case 'subscriptions':
          newEmailPrefs = currentEmail.copyWith(subscriptions: value);
          break;
        case 'social':
          newEmailPrefs = currentEmail.copyWith(social: value);
          break;
        case 'events':
          newEmailPrefs = currentEmail.copyWith(events: value);
          break;
        case 'financial':
          newEmailPrefs = currentEmail.copyWith(financial: value);
          break;
        default:
          return;
      }

      final updatedPrefs = _notificationPreferences!.copyWith(email: newEmailPrefs);
      await _updateNotificationPreferences(updatedPrefs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления настроек: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateDatabasePreference(String key, bool value) async {
    if (_notificationPreferences == null) return;
    
    try {
      final currentDatabase = _notificationPreferences!.database;
      DatabasePreferences newDatabasePrefs;

      switch (key) {
        case 'subscriptions':
          newDatabasePrefs = currentDatabase.copyWith(subscriptions: value);
          break;
        case 'social':
          newDatabasePrefs = currentDatabase.copyWith(social: value);
          break;
        case 'events':
          newDatabasePrefs = currentDatabase.copyWith(events: value);
          break;
        case 'financial':
          newDatabasePrefs = currentDatabase.copyWith(financial: value);
          break;
        default:
          return;
      }

      final updatedPrefs = _notificationPreferences!.copyWith(database: newDatabasePrefs);
      await _updateNotificationPreferences(updatedPrefs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления настроек: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateNotificationPreferences(NotificationPreferences preferences) async {
    try {
      final response = await _apiClient.put('/preferences', data: {
        'preferences': preferences.toJson(),
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          setState(() {
            _notificationPreferences = preferences;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Настройки успешно обновлены'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления настроек: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTopupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Пополнение баланса',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Функция пополнения баланса будет доступна в ближайшее время.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: Color(0xFF6B46C1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog() {
    // TODO: Получить текущую подписку из API
    final mockSubscription = Subscription(
      id: 1,
      userId: _currentUser.id,
      productId: 1,
      status: 'active',
      startsAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      amount: 1000,
      currency: 'RUB',
      autoRenew: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      user: null,
      product: null,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubscriptionScreen(
          currentSubscription: mockSubscription,
          availablePlans: [], // TODO: Загрузить планы из API
          user: widget.user,
          subscriptionStatus: widget.subscriptionStatus,
          products: widget.products,
        ),
      ),
    );
  }

  void _navigateToTransactions() {
    // TODO: Загрузить транзакции из API
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionsScreen(
          transactions: [], // TODO: Загрузить транзакции из API
          currentBalance: _currentUser.balance,
        ),
      ),
    );
  }
}

// Диалог смены пароля
class _ChangePasswordDialog extends StatefulWidget {
  final Function(String currentPassword, String newPassword) onPasswordChanged;

  const _ChangePasswordDialog({required this.onPasswordChanged});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: const Text(
        'Изменить пароль',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Текущий пароль',
                labelStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6B46C1)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите текущий пароль';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                labelStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6B46C1)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите новый пароль';
                }
                if (value.length < 8) {
                  return 'Пароль должен содержать минимум 8 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                labelStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6B46C1)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Подтвердите пароль';
                }
                if (value != _newPasswordController.text) {
                  return 'Пароли не совпадают';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Отмена',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onPasswordChanged(
                _currentPasswordController.text,
                _newPasswordController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Изменить',
            style: TextStyle(color: Color(0xFF6B46C1)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// Диалог пополнения баланса
class _TopUpDialog extends StatefulWidget {
  final Function(double amount) onTopUp;

  const _TopUpDialog({required this.onTopUp});

  @override
  State<_TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<_TopUpDialog> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: const Text(
        'Пополнить баланс',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Введите сумму для пополнения баланса',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Сумма (₽)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6B46C1)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите сумму';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Введите корректную сумму';
                }
                if (amount < 10) {
                  return 'Минимальная сумма: 10 ₽';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Отмена',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text);
              widget.onTopUp(amount);
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Пополнить',
            style: TextStyle(color: Color(0xFF6B46C1)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

// Диалог редактирования профиля
class _ProfileEditDialog extends StatefulWidget {
  final User user;
  final ApiClient apiClient;
  final Function(String avatarUrl) onAvatarChanged;
  final VoidCallback onAvatarDeleted;
  final Function(User updatedUser) onUserUpdated;

  const _ProfileEditDialog({
    required this.user,
    required this.apiClient,
    required this.onAvatarChanged,
    required this.onAvatarDeleted,
    required this.onUserUpdated,
  });

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  // final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstnameController;
  late final TextEditingController _lastnameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late bool _auto;
  late bool _psyLance;

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController(text: widget.user.firstname ?? '');
    _lastnameController = TextEditingController(text: widget.user.lastname ?? '');
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _auto = widget.user.auto;
    _psyLance = widget.user.psyLance;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: const Text(
        'Редактировать профиль',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватар
              Center(
                child: GestureDetector(
                  onTap: _showAvatarOptions,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF6B46C1),
                        child: widget.user.avatar != null 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  widget.user.avatar!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                widget.user.fullName.isNotEmpty ? widget.user.fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B46C1),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.user.email,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstnameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Имя',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6B46C1))),
                      ),
                      maxLength: 255,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastnameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Фамилия',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6B46C1))),
                      ),
                      maxLength: 255,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6B46C1))),
                ),
                maxLength: 20,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'О себе',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6B46C1))),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Автопродление подписки', style: TextStyle(color: Colors.white)),
                subtitle: const Text('auto', style: TextStyle(color: Colors.grey)),
                value: _auto,
                activeColor: const Color(0xFF6B46C1),
                onChanged: (v) => setState(() => _auto = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('PsyLance', style: TextStyle(color: Colors.white)),
                subtitle: const Text('psy_lance', style: TextStyle(color: Colors.grey)),
                value: _psyLance,
                activeColor: const Color(0xFF6B46C1),
                onChanged: (v) => setState(() => _psyLance = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Закрыть',
            style: TextStyle(color: Color(0xFF6B46C1)),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _saveProfile,
          child: const Text(
            'Сохранить',
            style: TextStyle(color: Color(0xFF6B46C1)),
          ),
        ),
      ],
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D2D),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выберите действие',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF6B46C1)),
              title: const Text(
                'Загрузка аватара в разработке',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Загрузка аватара в разработке')),
                );
              },
            ),
            if (widget.user.avatar != null) ...[
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Удалить аватар',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAvatar();
                },
              ),
            ],
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Загрузка аватара временно отключена

  Future<void> _deleteAvatar() async {
    try {
      setState(() => _isLoading = true);
      
      widget.onAvatarDeleted();
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении аватара: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoading = true);
      final payload = {
        if (_firstnameController.text.trim().isNotEmpty) 'firstname': _firstnameController.text.trim(),
        if (_lastnameController.text.trim().isNotEmpty) 'lastname': _lastnameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        'auto': _auto,
        'psy_lance': _psyLance,
      };

      final response = await widget.apiClient.put('/profile', data: payload);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // Обновим локального пользователя
        final updated = User(
          id: widget.user.id,
          firstname: _firstnameController.text.trim().isEmpty ? widget.user.firstname : _firstnameController.text.trim(),
          lastname: _lastnameController.text.trim().isEmpty ? widget.user.lastname : _lastnameController.text.trim(),
          email: widget.user.email,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
          avatar: widget.user.avatar,
          balance: widget.user.balance,
          formattedBalance: widget.user.formattedBalance,
          emailVerifiedAt: widget.user.emailVerifiedAt,
          auto: _auto,
          psyLance: _psyLance,
          role: widget.user.role,
          createdAt: widget.user.createdAt,
          updatedAt: DateTime.now(),
        );
        widget.onUserUpdated(updated);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Профиль обновлен'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при сохранении профиля: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}