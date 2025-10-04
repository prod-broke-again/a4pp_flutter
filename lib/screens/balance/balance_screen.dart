import 'package:flutter/material.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  String _selectedAmount = '1000';
  String _selectedPaymentMethod = 'card';
  final List<String> _amounts = ['500', '1000', '2000', '5000', '10000', 'custom'];

  @override
  Widget build(BuildContext context) {
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
          'Пополнение баланса',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Текущий баланс
              Container(
                width: double.infinity,
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
                      color: const Color(0xFF6B46C1).withAlpha(102),
                      spreadRadius: 4,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Текущий баланс',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        fontSize: 16,
                        
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '₽ 15,000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceStat(
                            icon: Icons.trending_up,
                            value: '+₽ 5,000',
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
                          child: _buildBalanceStat(
                            icon: Icons.trending_down,
                            value: '-₽ 2,000',
                            label: 'Расходы',
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Сумма пополнения
              const Text(
                'Сумма пополнения',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Быстрые суммы
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _amounts.length,
                itemBuilder: (context, index) {
                  final amount = _amounts[index];
                  final isSelected = _selectedAmount == amount;
                  final isCustom = amount == 'custom';
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAmount = amount;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF6B46C1)
                            : const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF6B46C1)
                              : Colors.grey[800]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isCustom ? 'Другая' : '₽ $amount',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Пользовательская сумма
              if (_selectedAmount == 'custom')
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromRGBO(107, 70, 193, 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Введите сумму',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                          hintText: '₽ 0',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: const Icon(
                            Icons.attach_money,
                            color: Color(0xFF6B46C1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF6B46C1),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1A1A1A),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Способ оплаты
              const Text(
                'Способ оплаты',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildPaymentMethod(
                icon: Icons.credit_card,
                title: 'Банковская карта',
                subtitle: 'Visa, MasterCard, МИР',
                value: 'card',
                isSelected: _selectedPaymentMethod == 'card',
              ),
              
              const SizedBox(height: 12),
              
              _buildPaymentMethod(
                icon: Icons.account_balance,
                title: 'Банковский перевод',
                subtitle: 'СБП, по реквизитам',
                value: 'bank',
                isSelected: _selectedPaymentMethod == 'bank',
              ),
              
              const SizedBox(height: 12),
              
              _buildPaymentMethod(
                icon: Icons.account_balance_wallet,
                title: 'Электронные кошельки',
                subtitle: 'ЮMoney, QIWI',
                value: 'wallet',
                isSelected: _selectedPaymentMethod == 'wallet',
              ),
              
              const SizedBox(height: 32),
              
              // Информация о комиссии
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Сумма пополнения',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(
                          '₽ ${_selectedAmount == 'custom' ? '0' : _selectedAmount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Комиссия',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(
                          '₽ 0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Итого к оплате',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₽ ${_selectedAmount == 'custom' ? '0' : _selectedAmount}',
                          style: const TextStyle(
                            color: Color(0xFF6B46C1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Кнопка пополнения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAmount != 'custom' || _selectedAmount.isNotEmpty
                      ? () {
                          // Логика пополнения баланса
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Пополнить баланс',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Информация о безопасности
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(5, 150, 105, 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromRGBO(5, 150, 105, 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: const Color(0xFF059669),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Все платежи защищены SSL-шифрованием. Ваши данные в безопасности.',
                        style: TextStyle(
                          color: const Color(0xFF059669),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceStat({
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
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color.fromRGBO(107, 70, 193, 0.1)
              : const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF6B46C1)
                : Colors.grey[800]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF6B46C1)
                    : const Color.fromRGBO(107, 70, 193, 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF6B46C1),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B46C1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
