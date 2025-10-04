import 'package:flutter/material.dart';
import 'package:mobile/models/meeting.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/subscription.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/models/profile_response.dart';
import 'package:mobile/services/meeting_service.dart';
import 'package:mobile/screens/meetings/meeting_create_screen.dart';
import '../../widgets/app_drawer.dart';

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
    const isDark = true; // Всегда темная тема

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('АЧПП'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            onPressed: _loadMeetings,
            icon: const Icon(Icons.refresh),
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
                'Консультации и мероприятия для профессионального развития и обмена опытом',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Поиск и фильтры
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: _search),
                      onChanged: (value) {
                        setState(() {
                          _search = value;
                          _loadMeetings(reset: true);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Поиск встреч...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        filled: true,
                        fillColor: const Color(0xFF2D2D2D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Фильтры
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(
                        labelText: 'Статус',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFF2D2D2D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      dropdownColor: const Color(0xFF2D2D2D),
                      style: const TextStyle(color: Colors.white),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Все статусы')),
                        const DropdownMenuItem(value: 'draft', child: Text('Черновик')),
                        const DropdownMenuItem(value: 'published', child: Text('Опубликовано')),
                        const DropdownMenuItem(value: 'completed', child: Text('Завершено')),
                        const DropdownMenuItem(value: 'cancelled', child: Text('Отменено')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _status = value;
                          _loadMeetings(reset: true);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _format,
                      decoration: InputDecoration(
                        labelText: 'Формат',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFF2D2D2D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      dropdownColor: const Color(0xFF2D2D2D),
                      style: const TextStyle(color: Colors.white),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Все форматы')),
                        const DropdownMenuItem(value: 'online', child: Text('Онлайн')),
                        const DropdownMenuItem(value: 'offline', child: Text('Оффлайн')),
                        const DropdownMenuItem(value: 'hybrid', child: Text('Гибридный')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _format = value;
                          _loadMeetings(reset: true);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Содержимое
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MeetingCreateScreen()),
          );
        },
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D1B1B),
                  borderRadius: BorderRadius.circular(48),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ошибка загрузки встреч',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadMeetings(reset: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    } else if (_meetings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2D1B),
                  borderRadius: BorderRadius.circular(48),
                ),
                child: const Icon(
                  Icons.event_note,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Нет встреч',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Проверьте фильтры или попробуйте позже',
                style: TextStyle(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _meetings.length + 1,
        itemBuilder: (context, index) {
          if (index == _meetings.length) {
            // Показываем индикатор загрузки для бесконечной прокрутки
            return _page < _lastPage
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox();
          }

          final meeting = _meetings[index];
          return _buildMeetingCard(meeting);
        },
      );
    }
  }

  Widget _buildMeetingCard(Meeting meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: meeting.status == 'published'
              ? const Color(0xFF8B5CF6).withAlpha(128)
              : Colors.grey[700]!,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(meeting.status).withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getStatusIcon(meeting.status),
            color: _getStatusColor(meeting.status),
            size: 24,
          ),
        ),
        title: Text(
          meeting.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              meeting.description ?? '',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  meeting.format == 'online' ? Icons.videocam : Icons.location_on,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  meeting.formatLabel,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  meeting.formattedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[600],
          size: 16,
        ),
        onTap: () {
          // TODO: Переход к деталям встречи
          print('Переход к встрече: ${meeting.name}');
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'published':
        return const Color(0xFF8B5CF6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'published':
        return Icons.event_available;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.event_note;
    }
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
