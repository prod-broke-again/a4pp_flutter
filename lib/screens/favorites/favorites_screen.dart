import 'package:flutter/material.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/subscription.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/models/course.dart';
import 'package:achpp/models/club.dart';
import '../../widgets/app_drawer.dart';
import 'package:achpp/services/auth_service.dart';
import '../courses/courses_screen.dart';
import '../courses/course_details_screen.dart';
import '../clubs/clubs_screen.dart';
import '../clubs/club_details_screen.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Избранное',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
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
                        Text(
                          'Ошибка загрузки избранного.\\n\\nПроверьте подключение к интернету и попробуйте снова.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Поиск в избранном...',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                          selectedColor: Theme.of(context).colorScheme.primary,
                          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                          labelStyle: TextStyle(
                            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
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
            Icon(
              Icons.favorite_border,
              size: 72,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'Все'
                  ? 'Ничего не найдено'
                  : 'У вас пока нет избранного',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'Все'
                  ? 'Попробуйте изменить фильтры или поисковый запрос'
                  : 'Откройте разделы и добавьте понравившиеся материалы в избранное.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
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
    Color cardColor = Theme.of(context).colorScheme.surfaceContainer;

    switch (type) {
      case 'App\\Models\\Club':
        title = favorable['name'] ?? favorable['title'] ?? 'Клуб';
        subtitle = 'Клуб';
        icon = Icons.group;
        break;
      case 'App\\Models\\Course':
        title = favorable['title'] ?? favorable['name'] ?? 'Курс';
        subtitle = 'Курс';
        icon = Icons.school;
        break;
      case 'App\\Models\\Meeting':
        title = favorable['name'] ?? favorable['title'] ?? 'Встреча';
        subtitle = 'Встреча';
        icon = Icons.event;
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
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          switch (type) {
            case 'App\\Models\\Course':
              // Переход к детальной странице курса
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailsScreen(
                    course: Course(
                      id: favorable['id'] ?? 0,
                      title: favorable['title'] ?? '',
                      slug: favorable['slug'] ?? '',
                      description: favorable['description'] ?? '',
                      shortDescription: favorable['short_description'] ?? '',
                      image: favorable['image'],
                      maxParticipants: favorable['max_participants'] ?? 0,
                      publishedAt: favorable['published_at'] != null
                          ? DateTime.tryParse(favorable['published_at'] ?? '')
                          : null,
                      formattedPublishedAt: favorable['formatted_published_at'] ?? '',
                      zoomLink: favorable['zoom_link'],
                      materialsFolderUrl: favorable['materials_folder_url'],
                      autoMaterials: favorable['auto_materials'] ?? false,
                      productLevel: favorable['product_level'] ?? 0,
                      isHidden: favorable['is_hidden'] ?? false,
                      isFavoritedByUser: true,
                      createdAt: DateTime.tryParse(favorable['created_at'] ?? '') ?? DateTime.now(),
                      updatedAt: DateTime.tryParse(favorable['updated_at'] ?? '') ?? DateTime.now(),
                      contentCount: favorable['content_count'] ?? 0,
                    ),
                  ),
                ),
              );
              break;
            case 'App\\Models\\Club':
              // Переход к детальной странице клуба
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClubDetailsScreen(
                    club: Club(
                      id: favorable['id'] ?? 0,
                      name: favorable['name'] ?? '',
                      slug: favorable['slug'] ?? '',
                      description: favorable['description'] ?? '',
                      image: favorable['image'],
                      zoomLink: favorable['zoom_link'],
                      materialsFolderUrl: favorable['materials_folder_url'],
                      autoMaterials: favorable['auto_materials'] ?? false,
                      currentDonations: (favorable['current_donations'] as num?)?.toDouble() ?? 0.0,
                      formattedCurrentDonations: favorable['formatted_current_donations'] ?? '',
                      status: favorable['status'] ?? '',
                      productLevel: favorable['product_level'] ?? 0,
                      owner: User(
                        id: favorable['owner']?['id'] ?? 0,
                        email: favorable['owner']?['email'] ?? '',
                        balance: (favorable['owner']?['balance'] as num?)?.toDouble() ?? 0.0,
                        auto: favorable['owner']?['auto'] ?? false,
                        psyLance: favorable['owner']?['psy_lance'] ?? false,
                        role: Role(
                          name: favorable['owner']?['role']?['name'] ?? '',
                          color: favorable['owner']?['role']?['color'] ?? '',
                        ),
                        createdAt: DateTime.tryParse(favorable['owner']?['created_at'] ?? '') ?? DateTime.now(),
                        updatedAt: DateTime.tryParse(favorable['owner']?['updated_at'] ?? '') ?? DateTime.now(),
                      ),
                      isFavoritedByUser: true,
                      createdAt: DateTime.tryParse(favorable['created_at'] ?? '') ?? DateTime.now(),
                      updatedAt: DateTime.tryParse(favorable['updated_at'] ?? '') ?? DateTime.now(),
                      speakers: favorable['speakers'] ?? '',
                    ),
                  ),
                ),
              );
              break;
            case 'App\\Models\\Meeting':
              // Переход к странице встреч
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeetingsScreen(
                    user: widget.user,
                    subscriptionStatus: widget.subscriptionStatus,
                    products: widget.products,
                  ),
                ),
              );
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Переход к $subtitle недоступен'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          }
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
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Следующее событие',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nextTitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (nextLine != null && nextLine.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          nextLine,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (speakers != null && speakers.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                speakers,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                        color: Theme.of(context).colorScheme.secondary.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Theme.of(context).colorScheme.secondary.withAlpha(77)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam, size: 14, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            'Zoom доступен',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
