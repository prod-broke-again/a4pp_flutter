import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:achpp/models/transaction.dart';

enum _Period { all, today, week, month }

class TransactionsScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final double currentBalance;

  const TransactionsScreen({super.key, required this.transactions, required this.currentBalance});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _Period _selected = _Period.all;

  List<Transaction> get _filteredTransactions {
    return widget.transactions.where((t) => _matchesPeriod(t.createdAt)).toList();
  }

  bool _matchesPeriod(DateTime date) {
    final now = DateTime.now();
    switch (_selected) {
      case _Period.all:
        return true;
      case _Period.today:
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case _Period.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = start.add(const Duration(days: 7));
        return date.isAfter(start.subtract(const Duration(milliseconds: 1))) && date.isBefore(end);
      case _Period.month:
        return date.year == now.year && date.month == now.month;
    }
  }

  void _setPeriod(_Period p) {
    if (_selected == p) return;
    setState(() {
      _selected = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total incomes and expenses based on filtered list
    final tx = _filteredTransactions;
    double totalIncomes = tx
        .where((t) => t.type == 'credit')
        .map((t) => t.amount)
        .fold(0.0, (sum, item) => sum + item);
    double totalExpenses = tx
        .where((t) => t.type == 'debit')
        .map((t) => t.amount)
        .fold(0.0, (sum, item) => sum + item);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'История транзакций',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<_Period>(
              onSelected: _setPeriod,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _Period.all,
                  child: Row(
                    children: [
                      if (_selected == _Period.all)
                        const Icon(Icons.check, size: 16),
                      if (_selected == _Period.all) const SizedBox(width: 6),
                      const Text('Все'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _Period.today,
                  child: Row(
                    children: [
                      if (_selected == _Period.today)
                        const Icon(Icons.check, size: 16),
                      if (_selected == _Period.today) const SizedBox(width: 6),
                      const Text('Сегодня'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _Period.week,
                  child: Row(
                    children: [
                      if (_selected == _Period.week)
                        const Icon(Icons.check, size: 16),
                      if (_selected == _Period.week) const SizedBox(width: 6),
                      const Text('Неделя'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _Period.month,
                  child: Row(
                    children: [
                      if (_selected == _Period.month)
                        const Icon(Icons.check, size: 16),
                      if (_selected == _Period.month) const SizedBox(width: 6),
                      const Text('Месяц'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Статистика
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B46C1),
                    const Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Общая статистика',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.trending_up,
                          value: '+₽ ${totalIncomes.toStringAsFixed(0)}',
                          label: 'Пополнения',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white30,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.trending_down,
                          value: '-₽ ${totalExpenses.toStringAsFixed(0)}',
                          label: 'Расходы',
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Текущий баланс:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₽ ${widget.currentBalance.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Фильтры по периодам
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPeriodFilter('Все', _selected == _Period.all, () => _setPeriod(_Period.all)),
                    const SizedBox(width: 12),
                    _buildPeriodFilter('Сегодня', _selected == _Period.today, () => _setPeriod(_Period.today)),
                    const SizedBox(width: 12),
                    _buildPeriodFilter('Неделя', _selected == _Period.week, () => _setPeriod(_Period.week)),
                    const SizedBox(width: 12),
                    _buildPeriodFilter('Месяц', _selected == _Period.month, () => _setPeriod(_Period.month)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Список транзакций
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionCard(_filteredTransactions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(230),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodFilter(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B46C1) : const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6B46C1) : Colors.grey[700]!,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final bool isPositive = transaction.type == 'credit';
    final String amountText = isPositive
        ? '+₽ ${transaction.amount.toStringAsFixed(0)}'
        : '-₽ ${transaction.amount.toStringAsFixed(0)}';
    final String formattedDate = DateFormat('d MMMM, HH:mm').format(transaction.createdAt);

    // Determine transaction type and icon
    IconData icon;
    String typeText;
    switch (transaction.relatedType) {
      case 'App\\Models\\Subscription':
        icon = Icons.subscriptions;
        typeText = 'Подписка';
        break;
      case 'App\\Models\\Course': // Assuming a Course model association
        icon = Icons.school;
        typeText = 'Курс';
        break;
      case 'App\\Models\\Club': // Assuming a Club model association
        icon = Icons.group;
        typeText = 'Клуб';
        break;
      case 'App\\Models\\Meeting': // Assuming a Meeting model association
        icon = Icons.psychology;
        typeText = 'Консультация';
        break;
      default:
        if (transaction.description.contains('Пополнение')) {
          icon = Icons.add_circle;
          typeText = 'Пополнение';
        } else if (transaction.description.contains('Возврат')) {
          icon = Icons.undo;
          typeText = 'Возврат';
        } else {
          icon = Icons.compare_arrows;
          typeText = 'Прочее';
        }
    }

    Color statusColor;
    switch (transaction.status) {
      case 'completed':
        statusColor = const Color(0xFF10B981);
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'failed':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = Colors.grey[600]!;
    }

    String statusText;
    switch (transaction.status) {
      case 'completed':
        statusText = 'Завершено';
        break;
      case 'pending':
        statusText = 'В обработке';
        break;
      case 'failed':
        statusText = 'Ошибка';
        break;
      case 'cancelled':
        statusText = 'Отменено';
        break;
      case 'refunded':
        statusText = 'Возврат';
        break;
      default:
        statusText = 'Неизвестно';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Иконка типа транзакции
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isPositive 
                    ? const Color.fromRGBO(16, 185, 129, 0.2)
                    : const Color.fromRGBO(239, 68, 68, 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isPositive 
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                size: 28,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Информация о транзакции
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          typeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        amountText,
                        style: TextStyle(
                          color: isPositive 
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    transaction.description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withAlpha(128),
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
