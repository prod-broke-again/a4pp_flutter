import 'package:flutter/material.dart';

class DonationDialog extends StatefulWidget {
  final String title;
  final String modelName;
  final List<int> fixedAmounts;
  final int minAmount;
  final void Function(int amount) onSubmit;

  const DonationDialog({
    super.key,
    required this.title,
    required this.modelName,
    required this.fixedAmounts,
    required this.minAmount,
    required this.onSubmit,
  });

  @override
  State<DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends State<DonationDialog> {
  late int _selectedAmount;
  bool _useCustom = false;
  final TextEditingController _customController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.fixedAmounts.first;
  }

  int get _donationAmount {
    if (_useCustom && _customController.text.isNotEmpty) {
      return int.tryParse(_customController.text) ?? 0;
    }
    return _selectedAmount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Название курса/клуба
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.modelName,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Выберите сумму поддержки',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.8,
                ),
                itemCount: widget.fixedAmounts.length,
                itemBuilder: (context, index) {
                  final amount = widget.fixedAmounts[index];
                  final selected = !_useCustom && _selectedAmount == amount;
                  return OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _useCustom = false;
                        _selectedAmount = amount;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: selected ? const Color(0xFF7C3AED) : (isDark ? const Color(0xFF2A2B2F) : const Color(0xFFE5E7EB)), width: 2),
                      backgroundColor: selected ? const Color(0xFF7C3AED).withOpacity(0.1) : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      '$amount₽',
                      style: TextStyle(
                        color: selected ? const Color(0xFF7C3AED) : (isDark ? Colors.white70 : const Color(0xFF111827)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _useCustom = true;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _useCustom ? const Color(0xFF7C3AED) : (isDark ? const Color(0xFF2A2B2F) : const Color(0xFFE5E7EB)), width: 2),
                  backgroundColor: _useCustom ? const Color(0xFF7C3AED).withOpacity(0.1) : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volunteer_activism, color: _useCustom ? const Color(0xFF7C3AED) : (isDark ? Colors.white70 : const Color(0xFF111827))),
                    const SizedBox(width: 8),
                    Text(
                      'Своя сумма',
                      style: TextStyle(
                        color: _useCustom ? const Color(0xFF7C3AED) : (isDark ? Colors.white70 : const Color(0xFF111827)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (_useCustom) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _customController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '${widget.minAmount}',
                    suffixText: '₽',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Минимальная сумма: ${widget.minAmount}₽',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF6B7280), fontSize: 12),
                ),
              ],

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? const Color(0xFF2A2B2F) : const Color(0xFFE5E7EB), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Отмена',
                        style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF111827), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _donationAmount < widget.minAmount)
                          ? null
                          : () async {
                              setState(() => _isSubmitting = true);
                              try {
                                widget.onSubmit(_donationAmount);
                              } finally {
                                if (mounted) setState(() => _isSubmitting = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSubmitting)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          else
                            const Icon(Icons.card_giftcard, size: 18),
                          const SizedBox(width: 8),
                          Text(_isSubmitting ? 'Отправляем...' : 'Поддержать'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


