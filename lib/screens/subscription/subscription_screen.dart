import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/subscription.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/services/auth_service.dart';
import '../../widgets/app_drawer.dart';

class SubscriptionScreen extends StatefulWidget {
  final Subscription currentSubscription;
  final List<Product> availablePlans;
  final User? user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;

  const SubscriptionScreen({
    super.key,
    required this.currentSubscription,
    required this.availablePlans,
    this.user,
    this.subscriptionStatus,
    this.products = const [],
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  Future<void> _handlePlanSelection(Product plan) async {
    // Если это текущий план, ничего не делаем
    if (plan.id == widget.currentSubscription.productId) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Проверяем, есть ли достаточный баланс
      final currentBalance = widget.user?.balance ?? 0.0;
      if (currentBalance < plan.price) {
        _showInsufficientFundsDialog(plan);
        return;
      }

      // Показываем диалог подтверждения
      final confirmed = await _showConfirmationDialog(plan);
      if (!confirmed) return;

      // Выполняем смену тарифа
      final result = await AuthService().changeTariff(
        productId: plan.id,
        durationMonths: 1, // По умолчанию на 1 месяц
      );

      if (result['success'] == true) {
        // Показываем успех
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Тариф успешно изменен на "${plan.name}"'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
        // Можно добавить обновление состояния или навигацию
      } else {
        throw Exception(result['message'] ?? 'Не удалось сменить тариф');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showConfirmationDialog(Product plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Подтверждение смены тарифа',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Вы действительно хотите сменить тариф на "${plan.name}"?\n\nСтоимость: ₽ ${plan.price.toStringAsFixed(0)}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Отмена', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _showInsufficientFundsDialog(Product plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Недостаточно средств',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        content: Text(
          'Для смены тарифа на "${plan.name}" требуется ₽ ${plan.price.toStringAsFixed(0)}, но на вашем балансе ₽ ${(widget.user?.balance ?? 0).toStringAsFixed(0)}.',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Закрыть', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Переход на экран пополнения баланса
              // Navigator.of(context).push(...);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Пополнить баланс'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Подписка',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Текущая подписка
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.currentSubscription.product?.name ?? 'Нет подписки',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Builder(builder: (context) {
                                final currentProduct = widget.currentSubscription.product ??
                                    (widget.availablePlans.where((p) => p.id == widget.currentSubscription.productId).isNotEmpty
                                        ? widget.availablePlans.firstWhere((p) => p.id == widget.currentSubscription.productId)
                                        : null);
                                final htmlDescription = currentProduct?.description;
                                if (htmlDescription == null || htmlDescription.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Html(
                                  data: htmlDescription,
                                  style: {
                                    'body': Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontSize: FontSize(14),
                                    ),
                                    'p': Style(margin: Margins.zero),
                                  },
                                );
                              }),
                              if (widget.currentSubscription.expiresAt != null)
                                Text(
                                  'Активна до ${DateFormat('d MMMM yyyy').format(widget.currentSubscription.expiresAt)}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 16,
                                  ),
                                )
                              else
                                Text(
                                  'Подписка не активна',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ваши преимущества:',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.currentSubscription.product?.features != null)
                      ...widget.currentSubscription.product!.features.map((feature) => _buildBenefitItem('✓ $feature'))
                    else
                      _buildBenefitItem('Нет активных преимуществ'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Доступные планы
              Text(
                'Доступные планы',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              ...widget.availablePlans.map((plan) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPlanCard(
                    plan: plan,
                    isCurrent: plan.id == widget.currentSubscription.productId,
                  ),
                );
              }),
              
              const SizedBox(height: 32),
              
              // Информация о подписке
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Важная информация',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem('• Подписка продлевается автоматически'),
                    _buildInfoItem('• Отменить можно в любое время'),
                    _buildInfoItem('• Возврат средств в течение 7 дней'),
                    _buildInfoItem('• Техническая поддержка включена'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required Product plan,
    required bool isCurrent,
  }) {
    // Example logic for recommended plan
    final bool isRecommended = plan.level == 'Premium';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? Theme.of(context).colorScheme.primary
              : isRecommended
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.outline,
          width: isCurrent || isRecommended ? 2 : 1,
        ),
        boxShadow: isCurrent || isRecommended
            ? [
                BoxShadow(
                  color: isCurrent
                      ? const Color.fromRGBO(107, 70, 193, 0.3)
                      : const Color.fromRGBO(245, 158, 11, 0.3),
                  spreadRadius: 3,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок плана
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((plan.description ?? '').isNotEmpty)
                        Html(
                          data: plan.description!,
                          style: {
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: FontSize(14),
                            ),
                            'p': Style(margin: Margins.zero),
                          },
                        ),
                    ],
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Рекомендуем',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Текущий',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Цена
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₽ ${plan.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  plan.durationDays > 31 ? 'в год' : 'в месяц',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Особенности
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Кнопка действия
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handlePlanSelection(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: isCurrent
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCurrent
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        isCurrent ? 'Текущий план' : 'Выбрать план',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
        ),
      );
  }

  // Удалён блок дополнительных услуг, как неиспользуемый в проекте

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
    );
  }
}

