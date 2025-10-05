import 'package:flutter/material.dart';
import 'package:achpp/models/course.dart';
import 'package:achpp/models/club.dart';
import 'package:achpp/widgets/donation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversalCard extends StatelessWidget {
  final dynamic item; // Course или Club
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDonate;
  final bool isDark;

  const UniversalCard({
    super.key,
    required this.item,
    this.onTap,
    this.onToggleFavorite,
    this.onDonate,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCourse = item is Course;
    final isClub = item is Club;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: _getImage() != null
                      ? DecorationImage(
                          image: NetworkImage(_getImage()!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: _getImage() == null 
                      ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6)) 
                      : null,
                ),
                child: _getImage() == null
                    ? Center(
                        child: Icon(
                          isCourse ? Icons.school_outlined : Icons.group_outlined,
                          color: isDark ? Colors.grey[600] : const Color(0xFF9CA3AF),
                          size: 48,
                        ),
                      )
                    : null,
              ),
              
              // Убрали статусы "Активен" и "Базовый" - оставляем только кнопку избранного
              
              // Кнопка избранного
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onToggleFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isFavorited() ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorited() ? const Color(0xFFEF4444) : (isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Информация
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    _getTitle(),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Описание
                Text(
                  _getDescription(),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                
                const SizedBox(height: 12),
                
                // Ближайшее занятие/встреча
                if (_getNextEvent() != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFDBEAFE),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCourse ? 'Ближайшее занятие' : 'Ближайшая встреча',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E40AF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(_getNextEventDate()),
                          style: TextStyle(
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                            fontSize: 12,
                          ),
                        ),
                        if (_getNextEventTitle() != null && _getNextEventTitle()!.isNotEmpty)
                          Text(
                            _getNextEventTitle()!,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        if (_getContentCount() != null)
                          Row(
                            children: [
                              Icon(
                                isCourse ? Icons.school : Icons.event,
                                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_getContentCount()} ${isCourse ? 'занятий' : 'встреч'} всего',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Кнопка "Подробнее"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility, size: 16),
                        SizedBox(width: 8),
                        Text('Подробнее'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Кнопки действий
                Row(
                  children: [
                    // Кнопка подключения к Zoom (для курсов и клубов)
                    if (_getZoomLink() != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openZoomLink(context, _getZoomLink()!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 1,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_call, size: 16),
                              SizedBox(width: 4),
                              Text('Подключиться', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    
                    if (_getZoomLink() != null) const SizedBox(width: 8),
                    
                    // Кнопка поддержки
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showDonationDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 1,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.card_giftcard, size: 16),
                            SizedBox(width: 4),
                            Text('Поддержать', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Геттеры для универсального доступа к данным
  String? _getImage() {
    if (item is Course) return (item as Course).image;
    if (item is Club) return (item as Club).image;
    return null;
  }

  String _getTitle() {
    if (item is Course) return (item as Course).title;
    if (item is Club) {
      final club = item as Club;
      // Показываем спикеров вместо названия клуба
      return club.speakers ?? club.name;
    }
    return '';
  }

  String _getDescription() {
    if (item is Course) {
      final course = item as Course;
      return course.shortDescription.isNotEmpty ? course.shortDescription : course.description;
    }
    if (item is Club) {
      final club = item as Club;
      return _stripHtmlTags(club.description);
    }
    return '';
  }

  String _stripHtmlTags(String htmlString) {
    // Удаляем HTML-теги и декодируем HTML-сущности
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '') // Удаляем все HTML-теги
        .replaceAll('&nbsp;', ' ') // Заменяем неразрывные пробелы
        .replaceAll('&amp;', '&') // Декодируем амперсанды
        .replaceAll('&lt;', '<') // Декодируем меньше
        .replaceAll('&gt;', '>') // Декодируем больше
        .replaceAll('&quot;', '"') // Декодируем кавычки
        .replaceAll('&#39;', "'") // Декодируем апострофы
        .replaceAll(RegExp(r'\s+'), ' ') // Заменяем множественные пробелы на один
        .trim(); // Убираем пробелы в начале и конце
  }

  bool _isFavorited() {
    if (item is Course) return (item as Course).isFavoritedByUser;
    if (item is Club) return (item as Club).isFavoritedByUser;
    return false;
  }

  String? _getZoomLink() {
    if (item is Course) return (item as Course).zoomLink;
    if (item is Club) return (item as Club).zoomLink;
    return null;
  }

  String? _getClubStatus() {
    if (item is Club) return (item as Club).status;
    return null;
  }

  int _getProductLevel() {
    if (item is Course) return (item as Course).productLevel;
    if (item is Club) return (item as Club).productLevel;
    return 1;
  }

  dynamic _getNextEvent() {
    if (item is Course) return (item as Course).nextContent;
    if (item is Club) return (item as Club).nextMeeting;
    return null;
  }

  DateTime? _getNextEventDate() {
    if (item is Course) return (item as Course).nextContent?.date;
    if (item is Club) {
      final dateStr = (item as Club).nextMeeting?.date;
      if (dateStr != null) {
        try {
          return DateTime.parse(dateStr);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  String? _getNextEventTitle() {
    if (item is Course) return (item as Course).nextContent?.title;
    if (item is Club) {
      final club = item as Club;
      // Для клубов показываем спикеров вместо названия встречи
      return club.nextMeeting?.speakers;
    }
    return null;
  }

  int? _getContentCount() {
    if (item is Course) return (item as Course).contentCount;
    if (item is Club) return (item as Club).meetings?.length;
    return null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Дата не указана';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _openZoomLink(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть ссылку'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ошибка выполнения действия. Попробуйте позже.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _showDonationDialog(BuildContext context) {
    final title = item is Course ? 'Поддержать курс' : 'Поддержать клуб';
    final modelName = _getTitle();
    
    showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return DonationDialog(
          title: title,
          modelName: modelName,
          fixedAmounts: const [100, 300, 500, 1000, 2000],
          minAmount: 10,
          onSubmit: (amount) {
            Navigator.of(context).pop();
            // Здесь можно добавить логику обработки доната
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Донат на сумму $amount₽ отправлен'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          },
        );
      },
    );
  }
}
