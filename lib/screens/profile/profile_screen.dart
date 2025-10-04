import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/subscription.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/models/profile_response.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/models/transaction.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_drawer.dart';
import '../settings/settings_screen.dart';
import '../subscription/subscription_screen.dart';
import '../transactions/transactions_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  late User _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profile = await _authService.getProfile();
      setState(() {
        _currentUser = profile.user;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Ошибка загрузки профиля: $e');
      setState(() {
        _isLoading = false;
      });
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
          'Профиль',
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
        user: _currentUser,
        subscriptionStatus: widget.subscriptionStatus,
        products: widget.products,
        currentIndex: 0,
        onIndexChanged: (_) {},
      ),
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
                    backgroundImage: _currentUser.avatar != null && _currentUser.avatar!.isNotEmpty
                        ? NetworkImage(_currentUser.avatar!)
                        : null,
                    child: (_currentUser.avatar == null || _currentUser.avatar!.isEmpty)
                        ? Text(
                            _currentUser.fullName.isNotEmpty && (_currentUser.lastname?.isNotEmpty ?? false)
                                ? '${_currentUser.fullName[0]}${_currentUser.lastname![0]}'
                                : _currentUser.fullName.isNotEmpty 
                                    ? _currentUser.fullName[0].toUpperCase()
                                    : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentUser.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentUser.formattedBalance ?? '₽ ${_currentUser.balance.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Текущая подписка
              if (widget.subscriptionStatus != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: _buildSubscriptionSummary(widget.subscriptionStatus!),
                ),
                const SizedBox(height: 24),
              ],

              // Меню профиля
              _buildMenuItem(
                icon: Icons.person,
                title: 'Редактировать профиль',
                subtitle: 'Имя, фамилия, email, телефон',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        user: _currentUser,
                        subscriptionStatus: widget.subscriptionStatus,
                        products: widget.products,
                      ),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.settings,
                title: 'Настройки',
                subtitle: 'Уведомления, безопасность, тема и прочее',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        user: _currentUser,
                        subscriptionStatus: widget.subscriptionStatus,
                        products: widget.products,
                      ),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.subscriptions,
                title: 'Подписка',
                subtitle: widget.subscriptionStatus?.isActive == true 
                    ? 'Активна до ${_formatDate(widget.subscriptionStatus!.expiresAt)}'
                    : 'Не активна',
                onTap: () {
                  if (widget.subscriptionStatus != null) {
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
                                userId: _currentUser.id,
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
                          user: _currentUser,
                          subscriptionStatus: widget.subscriptionStatus,
                          products: widget.products,
                        ),
                      ),
                    );
                  }
                },
              ),

              _buildMenuItem(
                icon: Icons.receipt_long,
                title: 'История транзакций',
                subtitle: 'Просмотр всех операций',
                onTap: () async {
                  try {
                    final raw = await _authService.getTransactions();
                    // Поддержка обоих форматов ответа API (data.transactions или transactions)
                    final List<dynamic> list = (raw['data']?['transactions'] ?? raw['transactions'] ?? []) as List<dynamic>;
                    final txs = list
                        .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
                        .map((e) => Transaction.fromJson(e))
                        .toList();

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionsScreen(
                          transactions: txs,
                          currentBalance: _currentUser.balance,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка загрузки транзакций: $e')),
                    );
                  }
                },
              ),

              _buildMenuItem(
                icon: Icons.account_balance_wallet,
                title: 'Пополнить баланс',
                subtitle: 'Добавить средства на счет',
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пополнение баланса в разработке')),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Кнопка обновления профиля
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loadProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Обновить профиль',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF8B5CF6),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Неизвестно';
    return '${date.day}.${date.month}.${date.year}';
  }

  Widget _buildSubscriptionSummary(SubscriptionStatus status) {
    final isActive = status.isActive == true;
    final productName = status.product?.name ?? 'Подписка';
    final expires = status.expiresAt;
    final now = DateTime.now();
    final remainingDays = expires != null
        ? (expires.difference(now).inDays.clamp(0, 100000))
        : null;
    // Цена/стоимость: сначала из текущей подписки, иначе ищем в списке products по product.id
    String? priceRaw = status.subscription?.amount?.toString();
    if ((priceRaw == null || priceRaw.isEmpty) && status.product?.id != null) {
      try {
        final match = widget.products.firstWhere((p) => p.id == status.product!.id);
        priceRaw = match.price?.toString();
      } catch (_) {}
    }
    final priceText = priceRaw != null && priceRaw.isNotEmpty ? '₽ $priceRaw' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.subscriptions, color: const Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                productName,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isActive ? 'Активна' : 'Не активна',
                style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (priceText != null)
          Text(
            'Стоимость: $priceText',
            style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 14, fontWeight: FontWeight.w600),
          ),
        if (priceText != null) const SizedBox(height: 4),
        if (expires != null)
          Text(
            'Действует до ${_formatDate(expires)}' + (remainingDays != null ? ' • Осталось ~ $remainingDays д.' : ''),
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        if (status.auto == true)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: const [
                Icon(Icons.autorenew, size: 14, color: Color(0xFF8B5CF6)),
                SizedBox(width: 4),
                Text('Автопродление включено', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }
}
