import 'package:flutter/material.dart';
import 'package:achpp/models/meeting.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/subscription.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/services/meeting_service.dart';
import '../../widgets/app_drawer.dart';
import 'package:achpp/screens/meetings/meeting_create_screen.dart';

class MeetingsScreen extends StatefulWidget {
  final User? user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;

  const MeetingsScreen({
    super.key,
    this.user,
    this.subscriptionStatus,
    this.products = const [],
  });

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MeetingService _meetingService = MeetingService();

  // Состояние списка встреч и пагинации
  List<Meeting> _meetings = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';
  String? _status; // draft, published, completed, cancelled
  String? _format; // online, offline, hybrid
  int _page = 1;
  int _lastPage = 1;
  final int _perPage = 15;

  @override
  void initState() {
    super.initState();
    _loadMeetings(reset: true);
  }

  Future<void> _loadMeetings({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _meetings = [];
      });
    }

    try {
      final result = await _meetingService.getMeetings(
        page: _page,
        perPage: _perPage,
        search: _search.isNotEmpty ? _search : null,
        status: _status,
        format: _format,
      );

      setState(() {
        _meetings = reset ? result.meetings : [..._meetings, ...result.meetings];
        _lastPage = (result.pagination['last_page'] as int?) ?? 1;
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
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Встречи'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final created = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MeetingCreateScreen(),
                ),
              );
              if (created != null) {
                // После успешного создания обновляем список
                _loadMeetings(reset: true);
              }
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
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
        child: Column(
          children: [
            // Описание
            Container(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: const Text(
                'Расписание консультаций и мероприятий',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),

            // Компактный недельный календарь
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Заголовок с кнопкой раскрытия
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) {
                            _search = v;
                          },
                          onSubmitted: (_) => _loadMeetings(reset: true),
                          decoration: InputDecoration(
                            hintText: 'Поиск встреч...',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Row(
                        children: [
                          // Кнопка фильтра статуса
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.filter_list, color: Colors.white),
                            onSelected: (value) {
                              setState(() {
                                _status = value == 'all' ? null : value;
                              });
                              _loadMeetings(reset: true);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'all', child: Text('Все статусы')),
                              PopupMenuItem(value: 'draft', child: Text('Черновик')),
                              PopupMenuItem(value: 'published', child: Text('Опубликована')),
                              PopupMenuItem(value: 'completed', child: Text('Завершена')),
                              PopupMenuItem(value: 'cancelled', child: Text('Отменена')),
                            ],
                          ),
                          const SizedBox(width: 8),
                          // Кнопка фильтра формата
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.video_settings, color: Colors.white),
                            onSelected: (value) {
                              setState(() {
                                _format = value == 'all' ? null : value;
                              });
                              _loadMeetings(reset: true);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'all', child: Text('Все форматы')),
                              PopupMenuItem(value: 'online', child: Text('Онлайн')),
                              PopupMenuItem(value: 'offline', child: Text('Офлайн')),
                              PopupMenuItem(value: 'hybrid', child: Text('Гибрид')),
                            ],
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showFullCalendar,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Полный',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Компактная неделя
                  _buildWeekView(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Ближайшие встречи
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Ближайшие встречи',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Список встреч с пагинацией
            Expanded(
              child: _isLoading && _meetings.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6B46C1)),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                const SizedBox(height: 12),
                                Text(_error!, style: const TextStyle(color: Colors.white)),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _loadMeetings(reset: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B46C1),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Повторить'),
                                )
                              ],
                            ),
                          ),
                        )
                      : (!_isLoading && _meetings.isEmpty)
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.event_busy, color: Colors.grey, size: 64),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Пока встреч нет',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _search.isNotEmpty || _status != null || _format != null
                                          ? 'Измените поиск или фильтры'
                                          : 'Загляните позже или откройте календарь',
                                      style: const TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () => _loadMeetings(reset: true),
                                          icon: const Icon(Icons.refresh, size: 16),
                                          label: const Text('Обновить'),
                                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                                        ),
                                        const SizedBox(width: 12),
                                        OutlinedButton.icon(
                                          onPressed: _showFullCalendar,
                                          icon: const Icon(Icons.calendar_month, size: 16),
                                          label: const Text('Календарь'),
                                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels >=
                                    notification.metrics.maxScrollExtent - 200 &&
                                !_isLoading &&
                                _page < _lastPage) {
                              _page += 1;
                              _loadMeetings();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _meetings.length + (_page < _lastPage ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _meetings.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(color: Color(0xFF6B46C1)),
                                  ),
                                );
                              }
                              return _buildMeetingCard(_meetings[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekView() {
    final weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final weekDates = [16, 17, 18, 19, 20, 21, 22]; // Текущая неделя
    final today = 18; // Сегодня - среда
    final meetingDates = [18, 20]; // Дни с встречами

    return Row(
      children: List.generate(7, (index) {
        final date = weekDates[index];
        final isToday = date == today;
        final hasMeeting = meetingDates.contains(date);
        
        return Expanded(
          child: GestureDetector(
            onTap: () => _onDateSelected(date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isToday 
                    ? const Color(0xFF6B46C1)
                    : hasMeeting 
                        ? const Color(0xFF6B46C1).withAlpha(51)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: hasMeeting && !isToday
                    ? Border.all(color: const Color(0xFF6B46C1).withAlpha(128), width: 1)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weekDays[index],
                    style: TextStyle(
                      color: isToday 
                          ? Colors.white
                          : Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.toString(),
                    style: TextStyle(
                      color: isToday 
                          ? Colors.white
                          : hasMeeting 
                              ? const Color(0xFF6B46C1)
                              : Colors.white,
                      fontSize: 16,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  if (hasMeeting) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isToday ? Colors.white : const Color(0xFF6B46C1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _onDateSelected(int date) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Выбрана дата: $date декабря'),
          backgroundColor: const Color(0xFF6B46C1),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showFullCalendar() {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF2D2D2D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Заголовок модального окна
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Полный календарь',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Полный календарь
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFullCalendarGrid(),
              ),
            ),
          ],
        ),
      ),
    );
    }
  }

  Widget _buildFullCalendarGrid() {
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    
    return Column(
      children: [
        // Навигация по месяцам
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
            ),
            const Text(
              'Декабрь 2024',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Дни недели
        Row(
          children: days.map((day) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )).toList(),
        ),
        
        const SizedBox(height: 8),
        
        // Календарная сетка
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final date = index + 1;
              final isToday = date == 18; // Mock today
              final hasEvent = [5, 12, 18, 20, 25].contains(date); // Mock events
              
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _onDateSelected(date);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday 
                        ? const Color(0xFF6B46C1)
                        : hasEvent 
                            ? const Color(0xFF6B46C1).withAlpha(77)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: hasEvent && !isToday
                        ? Border.all(color: const Color(0xFF6B46C1), width: 1)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      date.toString(),
                      style: TextStyle(
                        color: isToday 
                            ? Colors.white
                            : hasEvent 
                                ? const Color(0xFF6B46C1)
                                : Colors.grey[300],
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingCard(Meeting meeting) {
    final bool isUpcoming = meeting.isUpcoming;
    final String timeFormat = meeting.formattedStartTime;
    final String dateFormat = meeting.formattedDate;

    Color statusColor;
    switch (meeting.status) {
      case 'upcoming':
        statusColor = const Color(0xFF10B981);
        break;
      case 'completed':
        statusColor = Colors.grey[600]!;
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUpcoming 
              ? const Color.fromRGBO(107, 70, 193, 0.3)
              : Colors.grey[800]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUpcoming 
                ? const Color(0xFF6B46C1).withAlpha(77) 
                : Colors.black.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и статус
            Row(
              children: [
                Expanded(
                  child: Text(
                    meeting.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withAlpha(128)),
                  ),
                  child: Text(
                    meeting.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Детали встречи
            Row(
              children: [
                Expanded(child: _buildMeetingDetail(Icons.schedule, timeFormat)),
                const SizedBox(width: 16),
                Expanded(child: _buildMeetingDetail(Icons.calendar_today, dateFormat)),
                const SizedBox(width: 16),
                Expanded(child: _buildMeetingDetail(Icons.videocam, meeting.platform ?? 'Платформа')),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Дополнительные детали
            Row(
              children: [
                Expanded(child: _buildMeetingDetail(Icons.access_time, meeting.duration)),
                const SizedBox(width: 16),
                Expanded(child: _buildMeetingDetail(Icons.person, meeting.organizer?.fullName ?? 'Организатор')),
                const SizedBox(width: 16),
                Expanded(child: _buildMeetingDetail(Icons.location_on, meeting.joinUrl ?? 'Место встречи')),
              ],
            ),
            
            const SizedBox(height: 20),
            
            const Divider(color: Colors.grey, height: 1),
            
            const SizedBox(height: 16),

            // Действия
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B46C1),
                      side: const BorderSide(color: Color(0xFF6B46C1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Детали',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (isUpcoming) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.video_call),
                      label: const Text('Присоединиться'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.history),
                      label: const Text('В архив'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF8B5CF6),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  String _calculateDuration(DateTime start, DateTime end) {
    final difference = end.difference(start);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}ч ${minutes}мин' : '${hours}ч';
    } else {
      return '${minutes}мин';
    }
  }
}
