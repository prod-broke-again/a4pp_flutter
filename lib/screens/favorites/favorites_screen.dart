import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/subscription.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/models/profile_response.dart';
import '../../widgets/app_drawer.dart';
import 'package:mobile/services/auth_service.dart';
import '../courses/courses_screen.dart';
import '../clubs/clubs_screen.dart';
import '../meetings/meetings_screen.dart';
import '../video_library/video_library_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favorites;
  final User? user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;

  const FavoritesScreen({
    Key? key,
    required this.favorites,
    this.user,
    this.subscriptionStatus,
    this.products = const [],
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  String _selectedFilter = 'Все';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['Все', 'Клубы', 'Курсы', 'Встречи'];

  List<Map<String, dynamic>> get _filteredFavorites {
    var filtered = _favorites.where((favorite) {
      final favorable = favorite['favorable'] as Map<String, dynamic>?;
      if (favorable == null) return false;

      // Фильтр по типу
      if (_selectedFilter != 'Все') {
        final type = favorite['favorable_type'] as String?;
        switch (_selectedFilter) {
          case 'Клубы':
            if (type != 'App\\Models\\Club') return false;
            break;
          case 'Курсы':
            if (type != 'App\\Models\\Course') return false;
            break;
          case 'Встречи':
            if (type != 'App\\Models\\Meeting') return false;
            break;
        }
      }

      // Поиск
      if (_searchQuery.isNotEmpty) {
        final title = (favorable['name'] ?? favorable['title'] ?? '').toString().toLowerCase();
        final description = (favorable['description'] ?? '').toString().toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return title.contains(searchLower) || description.contains(searchLower);
      }

      return true;
    }).toList();

    // Сортировка: сначала клубы, потом курсы, потом встречи
    filtered.sort((a, b) {
      final typeA = a['favorable_type'] as String?;
      final typeB = b['favorable_type'] as String?;
      
      int getOrder(String? type) {
        switch (type) {
          case 'App\\Models\\Club': return 0;
          case 'App\\Models\\Course': return 1;
          case 'App\\Models\\Meeting': return 2;
          default: return 3;
        }
      }
      
      return getOrder(typeA).compareTo(getOrder(typeB));
    });

    return filtered;
  }

  List<Map<String, dynamic>> _favorites = [];
  bool _loadingFavorites = true;
  String? _favoritesError;

  @override
  void initState() {
    super.initState();
    _favorites = widget.favorites; // может быть пустым при первом заходе
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _loadingFavorites = true;
      _favoritesError = null;
    });
    try {
      final data = await _authService.getFavorites();
      final list = (data['data']?['favorites'] ?? data['favorites'] ?? []) as List<dynamic>;
      final parsed = list
          .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .toList();
      setState(() {
        _favorites = parsed;
        _loadingFavorites = false;
      });
    } catch (e) {
      setState(() {
        _favoritesError = e.toString();
        _loadingFavorites = false;
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
          'Избранное',
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
        currentIndex: 0,
        onIndexChanged: (_) {},
      ),
      body: _loadingFavorites
          ? const Center(child: CircularProgressIndicator())
          : _favoritesError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Ошибка загрузки избранного.\\n\\nПроверьте подключение к интернету и попробуйте снова.',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _loadFavorites,
                          child: const Text('Повторить'),
                        )
                      ],
                    ),
                  ),
                )
              : Column(
        children: [
          // Поиск и фильтры
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Поиск
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Поиск в избранном...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF2D2D2D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                // Фильтры
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = filter);
                            }
                          },
                          selectedColor: const Color(0xFF6B46C1),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          backgroundColor: const Color(0xFF2D2D2D),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF6B46C1) : Colors.grey[600]!,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Список избранного
          Expanded(
            child: _filteredFavorites.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredFavorites.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteCard(_filteredFavorites[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'Все'
                  ? 'Ничего не найдено'
                  : 'У вас пока нет избранного',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'Все'
                  ? 'Попробуйте изменить фильтры или поисковый запрос'
                  : 'Откройте разделы и добавьте понравившиеся материалы в избранное.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty && _selectedFilter == 'Все') ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickActionButton(
                    icon: Icons.school,
                    label: 'Курсы',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CoursesScreen(
                          user: widget.user,
                          subscriptionStatus: widget.subscriptionStatus,
                          products: widget.products,
                        ),
                      ),
                    ),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.group,
                    label: 'Клубы',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClubsScreen(
                          user: widget.user,
                          subscriptionStatus: widget.subscriptionStatus,
                          products: widget.products,
                        ),
                      ),
                    ),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.event,
                    label: 'Встречи',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeetingsScreen(
                          user: widget.user,
                          subscriptionStatus: widget.subscriptionStatus,
                          products: widget.products,
                        ),
                      ),
                    ),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.video_library,
                    label: 'Видеотека',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VideoLibraryScreen(rootFolders: [])),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF6B46C1),
        side: const BorderSide(color: Color(0xFF6B46C1)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
    final favorable = favorite['favorable'] as Map<String, dynamic>?;
    final type = favorite['favorable_type'] as String?;
    
    if (favorable == null) return const SizedBox.shrink();

    String title = '';
    String subtitle = '';
    IconData icon = Icons.favorite;
    Color cardColor = const Color(0xFF2D2D2D);

    switch (type) {
      case 'App\\Models\\Club':
        title = favorable['name'] ?? favorable['title'] ?? 'Клуб';
        subtitle = 'Клуб';
        icon = Icons.group;
        cardColor = const Color(0xFF2D2D2D);
        break;
      case 'App\\Models\\Course':
        title = favorable['title'] ?? favorable['name'] ?? 'Курс';
        subtitle = 'Курс';
        icon = Icons.school;
        cardColor = const Color(0xFF2D2D2D);
        break;
      case 'App\\Models\\Meeting':
        title = favorable['name'] ?? favorable['title'] ?? 'Встреча';
        subtitle = 'Встреча';
        icon = Icons.event;
        cardColor = const Color(0xFF2D2D2D);
        break;
      default:
        title = favorable['name'] ?? favorable['title'] ?? 'Элемент';
        subtitle = 'Избранное';
    }

    final String? description = favorable['description']?.toString();
    final String? zoomLink = favorable['zoom_link']?.toString();
    final Map<String, dynamic>? nextMeeting = favorable['next_meeting'] as Map<String, dynamic>?;
    final Map<String, dynamic>? nextContent = favorable['next_content'] as Map<String, dynamic>?;

    String? nextLine;
    String? nextTitle;
    String? speakers;
    if (nextMeeting != null && nextMeeting.isNotEmpty) {
      final date = nextMeeting['date']?.toString();
      final start = nextMeeting['start_time']?.toString();
      final end = nextMeeting['end_time']?.toString();
      nextLine = _formatEventDateTime(date, start, end);
      nextTitle = nextMeeting['name']?.toString();
      speakers = nextMeeting['speakers']?.toString();
    } else if (nextContent != null && nextContent.isNotEmpty) {
      final titleC = nextContent['title']?.toString();
      final date = nextContent['date']?.toString();
      final start = nextContent['start_time']?.toString();
      final end = nextContent['end_time']?.toString();
      nextLine = _formatEventDateTime(date, start, end);
      nextTitle = titleC;
      speakers = nextContent['speakers']?.toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Навигация к конкретному элементу
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Переход к $subtitle: $title'),
              backgroundColor: const Color(0xFF6B46C1),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и тип
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1).withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFF6B46C1), size: 20),
                  ),
                  const SizedBox(width: 12),
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
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              
              // Описание
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _stripHtmlTags(description),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[300],
                    height: 1.4,
                  ),
                ),
              ],
              
              // Следующее событие
              if (nextTitle != null && nextTitle.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF6B46C1).withAlpha(77)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16, color: Color(0xFF6B46C1)),
                          const SizedBox(width: 6),
                          Text(
                            'Следующее событие',
                            style: TextStyle(
                              color: const Color(0xFF6B46C1),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nextTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (nextLine != null && nextLine.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          nextLine,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (speakers != null && speakers.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                speakers,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              // Индикаторы
              const SizedBox(height: 12),
              Row(
                children: [
                  if (zoomLink != null && zoomLink.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.withAlpha(77)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.videocam, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          const Text(
                            'Zoom доступен',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  Text(
                    'Добавлено ${_formatDate(favorite['created_at'])}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
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

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'сегодня';
      } else if (difference.inDays == 1) {
        return 'вчера';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} дн. назад';
      } else {
        return '${date.day}.${date.month}.${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatEventDateTime(String? dateIso, String? startIso, String? endIso) {
    try {
      DateTime? date;
      DateTime? start;
      DateTime? end;

      if (dateIso != null && dateIso.isNotEmpty) {
        date = DateTime.tryParse(dateIso);
      }
      if (startIso != null && startIso.isNotEmpty) {
        start = DateTime.tryParse(startIso);
      }
      if (endIso != null && endIso.isNotEmpty) {
        end = DateTime.tryParse(endIso);
      }

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

      if (datePart == null && startPart == null && endPart == null) return '';

      // Сборка строки: 24.09.2025 • 12:00–13:30
      final timePart = endPart != null && startPart != null
          ? '$startPart–$endPart'
          : (startPart ?? endPart);

      return [datePart, timePart].where((e) => e != null && e!.isNotEmpty).join(' • ');
    } catch (e) {
      return [dateIso, startIso].where((e) => e != null && e!.isNotEmpty).join(' • ');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}