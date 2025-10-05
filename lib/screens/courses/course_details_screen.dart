import 'package:flutter/material.dart';
import 'package:achpp/models/course.dart';
import 'package:achpp/services/auth_service.dart';
import 'package:achpp/widgets/donation_dialog.dart';
import 'package:achpp/utils/intl_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final AuthService _authService = AuthService();
  Course? _course;
  bool _isLoading = true;
  String? _error;
  bool _canAccess = false;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _authService.getCourse(widget.course.slug);
      setState(() {
        _course = Course.fromJson(data['course'] as Map<String, dynamic>);
        _canAccess = (data['can_access'] == true);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
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
                          'Ошибка загрузки курса:\n\n$_error',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _loadCourseDetails,
                          child: const Text('Повторить'),
                        )
                      ],
                    ),
                  ),
                )
              : _course == null
                  ? const Center(
                      child: Text(
                        'Курс не найден',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 280,
                          pinned: true,
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                _course!.image != null && _course!.image!.isNotEmpty
                                    ? Image.network(
                                        _course!.image!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: const Color(0xFF6B46C1),
                                          child: const Icon(Icons.school, color: Colors.white, size: 64),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0xFF6B46C1),
                                        child: const Icon(Icons.school, color: Colors.white, size: 64),
                                      ),
                                // Градиент для читаемости
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color(0xCC000000),
                                        Color(0x00000000),
                                      ],
                                    ),
                                  ),
                                ),
                                // Убраны лейблы "Курс" и уровень доступа
                                // Название курса
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Text(
                                    _course!.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Действия: Подключиться + Поддержать (в одном месте)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Builder(
                                        builder: (context) {
                                          final hasZoom = _course!.zoomLink != null && _course!.zoomLink!.isNotEmpty;
                                          if (hasZoom && _canAccess) {
                                            return ElevatedButton.icon(
                                              onPressed: () => _openLink(_course!.zoomLink!),
                                              icon: const Icon(Icons.play_arrow),
                                              label: const Text('Подключиться'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF2563EB),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            );
                                          }
                                          if (! _canAccess) {
                                            final needUpgrade = (_course!.productLevel > 1);
                                            return ElevatedButton.icon(
                                              onPressed: _openSubscription,
                                              icon: const Icon(Icons.shopping_bag_outlined),
                                              label: Text(needUpgrade ? 'Улучшить тариф' : 'Выбрать тариф'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFF59E0B),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            );
                                          }
                                          return OutlinedButton(
                                            onPressed: null,
                                            style: OutlinedButton.styleFrom(
                                              disabledForegroundColor: Colors.grey,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: const Text('Изучить курс'),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _openDonation(),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFFEC4899)),
                                          foregroundColor: const Color(0xFFEC4899),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        icon: const Icon(Icons.card_giftcard, size: 18),
                                        label: const Text('Поддержать курс'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_course!.materialsFolderUrl != null && _course!.materialsFolderUrl!.isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    child: Builder(
                                      builder: (context) {
                                        if (_canAccess) {
                                          return OutlinedButton.icon(
                                            onPressed: () => _openLink(_course!.materialsFolderUrl!),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Color(0xFF10B981)),
                                              foregroundColor: const Color(0xFF10B981),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            icon: const Icon(Icons.folder_open, size: 18),
                                            label: const Text('Открыть материалы'),
                                          );
                                        }
                                        final needUpgrade = (_course!.productLevel > 1);
                                        return ElevatedButton.icon(
                                          onPressed: _openSubscription,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFF59E0B),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: const Icon(Icons.shopping_bag_outlined),
                                          label: Text(needUpgrade ? 'Улучшить тариф для материалов' : 'Выбрать тариф для материалов'),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 24),

                                // О курсе (без автора)
                                const Text(
                                  'О курсе',
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _stripHtmlTags(
                                    _course!.description.isNotEmpty
                                        ? _course!.description
                                        : (_course!.shortDescription.isNotEmpty
                                            ? _course!.shortDescription
                                            : (_course!.image != null ? '' : 'Описание будет добавлено позже')),
                                  ),
                                  style: TextStyle(color: Colors.grey[300], height: 1.5),
                                ),

                                const SizedBox(height: 24),

                                // Материалы курса
                                if (_course!.materialsFolderUrl != null && _course!.materialsFolderUrl!.isNotEmpty) ...[
                                  const Text(
                                    'Материалы',
                                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D2D2D),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[800]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.green.withAlpha(32),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.folder, color: Colors.green, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _canAccess ? 'Материалы доступны' : 'Материалы по подписке',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        if (_canAccess)
                                          OutlinedButton.icon(
                                            onPressed: () => _openLink(_course!.materialsFolderUrl!),
                                            icon: const Icon(Icons.open_in_new, size: 16),
                                            label: const Text('Открыть'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              side: const BorderSide(color: Color(0xFF6B46C1)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // Ближайшее занятие
                                if (_course!.nextContent != null) ...[
                                  const Text(
                                    'Ближайшее занятие',
                                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildNextContentCard(_course!.nextContent!),
                                  const SizedBox(height: 24),
                                ],

                                // Программа курса (если есть)
                                if ((_course!.contentCount ?? 0) > 0 || _course!.contents.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      const Text(
                                        'Программа курса',
                                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2D2D2D),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.grey[800]!),
                                        ),
                                        child: Text(
                                          formatCountRu(
                                            _course!.contentCount ?? _course!.contents.length,
                                            ['занятие','занятия','занятий'],
                                          ),
                                          style: TextStyle(color: Colors.grey[300], fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildContentsList(),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildMetaTile({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today, color: Color(0xFF6B46C1), size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNextContentCard(CourseContent content) {
    final date = content.date?.toIso8601String();
    final start = content.startTime?.toIso8601String();
    final end = content.endTime?.toIso8601String();
    final dateLine = _formatEventDateTime(date, start, end);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.play_circle_outline, color: Color(0xFF6B46C1), size: 18),
              SizedBox(width: 6),
              Text('Следующее занятие', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          if (dateLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(dateLine, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
          if (content.speakers != null && content.speakers!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(content.speakers!, style: TextStyle(color: Colors.grey[400], fontSize: 12))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _stripHtmlTags(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  String _formatEventDateTime(String? dateIso, String? startIso, String? endIso) {
    try {
      DateTime? date;
      DateTime? start;
      DateTime? end;
      if (dateIso != null && dateIso.isNotEmpty) date = DateTime.tryParse(dateIso);
      if (startIso != null && startIso.isNotEmpty) start = DateTime.tryParse(startIso);
      if (endIso != null && endIso.isNotEmpty) end = DateTime.tryParse(endIso);

      String? datePart;
      if (date != null) {
        final dd = date.day.toString().padLeft(2, '0');
        final mm = date.month.toString().padLeft(2, '0');
        final yyyy = date.year.toString();
        datePart = '$dd.$mm.$yyyy';
      }

      String? startPart;
      if (start != null) {
        final hh = start.hour.toString().padLeft(2, '0');
        final min = start.minute.toString().padLeft(2, '0');
        startPart = '$hh:$min';
      }

      String? endPart;
      if (end != null) {
        final hh = end.hour.toString().padLeft(2, '0');
        final min = end.minute.toString().padLeft(2, '0');
        endPart = '$hh:$min';
      }

      final timePart = endPart != null && startPart != null
          ? '$startPart–$endPart'
          : (startPart ?? endPart ?? '');
      final parts = [datePart, if (timePart.isNotEmpty) timePart].whereType<String>().toList();
      return parts.join(' • ');
    } catch (_) {
      return [dateIso, startIso].where((e) => e != null && e!.isNotEmpty).join(' • ');
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть ссылку')),
        );
      }
    }
  }

  void _openSubscription() {
    // Навигация в раздел подписок приложения
    // Если у вас есть именованный маршрут, замените на Navigator.pushNamed(context, '/subscription');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Откройте раздел подписки для изменения тарифа'),
        backgroundColor: Color(0xFFF59E0B),
      ),
    );
  }

  Widget _buildContentsListPlaceholder() {
    // Заглушка под будущий список занятий (при наличии расширенного API)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Text(
        'Список занятий будет доступен позже',
        style: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildContentsList() {
    final items = _course!.contents;
    if (items.isEmpty) return _buildContentsListPlaceholder();

    return Column(
      children: [
        for (int index = 0; index < items.length; index++)
          Container(
            margin: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Color(0xFF6B46C1), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[index].title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      if ((items[index].description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          items[index].description!,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          if ((items[index].formattedDate ?? '').isNotEmpty)
                            _chip(
                              context: context,
                              icon: Icons.calendar_today,
                              text: items[index].formattedDate!,
                            ),
                          if ((items[index].formattedStartTime ?? '').isNotEmpty)
                            _chip(
                              context: context,
                              icon: Icons.schedule,
                              text: (items[index].formattedEndTime ?? '').isNotEmpty
                                  ? '${items[index].formattedStartTime}–${items[index].formattedEndTime}'
                                  : items[index].formattedStartTime!,
                            ),
                          if ((items[index].speakers ?? '').isNotEmpty)
                            _chip(
                              context: context,
                              icon: Icons.person,
                              text: items[index].speakers!,
                              maxWidth: MediaQuery.of(context).size.width * 0.6,
                            ),
                          if ((items[index].section ?? '').isNotEmpty)
                            _chip(
                              context: context,
                              icon: Icons.local_offer_outlined,
                              text: items[index].section!,
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _chip({required BuildContext context, required IconData icon, required String text, double? maxWidth}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? MediaQuery.of(context).size.width * 0.5,
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[300], fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDonation() async {
    if (_course == null) return;
    showDialog(
      context: context,
      builder: (context) => DonationDialog(
        title: 'Поддержать курс',
        modelName: _course!.title,
        fixedAmounts: const [100, 300, 500, 1000, 2000, 5000],
        minAmount: 50,
        onSubmit: (amount) async {
          Navigator.of(context).pop();
          try {
            final data = await _authService.donateToCourse(_course!.slug, amount.toDouble());
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Спасибо! Транзакция #${data['transaction_id'] ?? ''}'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка доната: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}


