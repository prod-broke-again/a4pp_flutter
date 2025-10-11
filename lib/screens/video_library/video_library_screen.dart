import 'package:flutter/material.dart';
import 'package:achpp/models/video.dart';
import 'package:achpp/models/video_folder.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:achpp/services/video_service.dart';
import 'package:achpp/screens/video_player/video_player_screen.dart';
import 'package:achpp/widgets/app_drawer.dart';

class VideoLibraryScreen extends StatefulWidget {
  final List<VideoFolder> rootFolders;
  final String title;
  final bool showAppBar;

  const VideoLibraryScreen({
    super.key,
    this.rootFolders = const [], // По умолчанию пустой список
    this.title = 'Видео',
    this.showAppBar = true,
  });

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  final VideoService _videoService = VideoService();
  final List<VideoFolder> _navigationStack = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredItems = []; // VideoFolder или Video
  bool _isSearchMode = false;
  bool _isLoadingFolder = false;
  bool _isLoadingRoot = false;

  @override
  void initState() {
    super.initState();
    _loadRootContent();
  }

  void _loadRootContent() async {
    if (widget.rootFolders.isNotEmpty) {
      print('📚 Видеотека: используем переданные папки (${widget.rootFolders.length} шт.)');
      if (mounted) {
        setState(() {
          _navigationStack.clear();
          _filteredItems = List.from(widget.rootFolders);
        });
      }
    } else {
      // Загружаем категории самостоятельно
      print('📚 Видеотека: загружаем категории с сервера...');
      if (mounted) {
        setState(() {
          _isLoadingRoot = true;
        });
      }
      try {
        final categories = await _videoService.getCategories();
        if (mounted) {
          setState(() {
            _navigationStack.clear();
            _filteredItems = List.from(categories);
            _isLoadingRoot = false;
          });
        }
        print('✅ Загружено ${categories.length} категорий');
      } catch (e) {
        print('❌ Ошибка загрузки категорий: $e');
        if (mounted) {
          setState(() {
            _navigationStack.clear();
            _filteredItems = [];
            _isLoadingRoot = false;
          });
        }
      }
    }
  }

  Future<void> _navigateToFolder(VideoFolder folder) async {
    if (!mounted) return;

    setState(() {
      _isLoadingFolder = true;
    });

    try {
      print('📂 Загружаем содержимое папки: ${folder.name} (ID: ${folder.id})');

      // API v2: category/{slug} возвращает videos и subcategories в одном ответе
      final result = await _videoService.getCategoryVideos(folder.slug);
      final videos = result.videos;
      final subcategoryFolders = result.subcategories;

      print('📁 Загружено подкатегорий: ${subcategoryFolders.length}, видео: ${videos.length}');

      if (mounted) {
        setState(() {
          // Сохраняем содержимое папки в самом объекте для корректного возврата назад
          final folderWithContent = VideoFolder(
            id: folder.id,
            name: folder.name,
            slug: folder.slug,
            description: folder.description,
            parentId: folder.parentId,
            sortOrder: folder.sortOrder,
            isActive: folder.isActive,
            createdAt: folder.createdAt,
            updatedAt: folder.updatedAt,
            videosCount: folder.videosCount,
            subcategoriesCount: folder.subcategoriesCount,
            totalVideosCount: folder.totalVideosCount,
            subfolders: subcategoryFolders,
            videos: videos,
          );
          _navigationStack.add(folderWithContent);
          _filteredItems = [...subcategoryFolders, ...videos];
          _isLoadingFolder = false;
        });
      }
    } catch (e) {
      print('❌ Ошибка загрузки содержимого папки: $e');
      if (mounted) {
        setState(() {
          _isLoadingFolder = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки содержимого папки. Попробуйте позже.')),
        );
      }
    }
  }

  void _navigateBack() {
    if (_navigationStack.isNotEmpty) {
      setState(() {
        _navigationStack.removeLast();
        if (_navigationStack.isEmpty) {
          _loadRootContent();
        } else {
          final currentFolder = _navigationStack.last;
          _filteredItems = [
            ...(currentFolder.subfolders ?? []),
            ...(currentFolder.videos ?? []),
          ];
        }
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearchMode = query.isNotEmpty;
      
      if (_isSearchMode) {
        _filteredItems = _searchInFolders(widget.rootFolders, query);
      } else {
        _loadCurrentFolderContent();
      }
    });
  }

  List<dynamic> _searchInFolders(List<VideoFolder> folders, String query) {
    final results = <dynamic>[];
    
    for (final folder in folders) {
      // Поиск в названии папки
      if (folder.name.toLowerCase().contains(query.toLowerCase())) {
        results.add(folder);
      }
      
      // Поиск в видео папки
      if (folder.videos != null) {
        for (final video in folder.videos!) {
          if (video.title.toLowerCase().contains(query.toLowerCase()) ||
              (video.description?.toLowerCase().contains(query.toLowerCase()) ?? false)) {
            results.add(video);
          }
        }
      }
      
      // Рекурсивный поиск в подпапках
      if (folder.subfolders != null) {
        results.addAll(_searchInFolders(folder.subfolders!, query));
      }
    }
    
    return results;
  }

  void _loadCurrentFolderContent() {
    if (_navigationStack.isEmpty) {
      _loadRootContent();
    } else {
      final currentFolder = _navigationStack.last;
      _filteredItems = [
        ...(currentFolder.subfolders ?? []),
        ...(currentFolder.videos ?? []),
      ];
    }
  }

  VideoFolder? get _currentFolder => _navigationStack.isNotEmpty ? _navigationStack.last : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: widget.showAppBar
          ? AppBar(
              title: _navigationStack.isNotEmpty
            ? Text(
                _currentFolder!.name,
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              )
            : Text(
                widget.title,
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              elevation: 0,
              leading: _navigationStack.isNotEmpty
                  ? IconButton(
                      onPressed: _navigateBack,
                      icon: const Icon(Icons.arrow_back),
                    )
                  : null,
            )
          : null,
      drawer: widget.showAppBar
          ? AppDrawer(
              user: null,
              subscriptionStatus: null,
              products: const [],
              currentIndex: 0,
              onIndexChanged: (_) {},
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Поиск
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Поиск видео и папок...',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                          icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),

            // Хлебные крошки скрыты по требованию

            // Контент
            Expanded(
              child: (_navigationStack.isEmpty && _isLoadingRoot) || _isLoadingFolder
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : _filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                _isSearchMode ? 'Ничего не найдено' : 'Папка пуста',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isSearchMode
                                    ? 'Попробуйте изменить поисковый запрос'
                                    : 'В этой папке пока нет видео',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 10),
                          itemCount: _filteredItems.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            if (item is VideoFolder) {
                              return _buildFolderCard(item);
                            } else if (item is Video) {
                              return _buildVideoCard(item);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderCard(VideoFolder folder) {
    // Используем данные из API для точной статистики
    final videosCount = folder.videosCount ?? folder.videos?.length ?? 0;
    final subfoldersCount = folder.subcategoriesCount ?? folder.subfolders?.length ?? 0;

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => _navigateToFolder(folder),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и стрелка в одном ряду
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      folder.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      softWrap: true,
                      maxLines: 4,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 2.0),
                    child: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),

              // Описание (если есть и не пустое после удаления HTML)
              () {
                final descriptionText = folder.description?.replaceAll(RegExp(r'<[^>]*>'), '').trim();
                return descriptionText?.isNotEmpty == true
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Html(
                          data: folder.description!,
                          style: {
                            'body': Style(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: FontSize(14),
                              lineHeight: LineHeight.number(1.4),
                            ),
                            'p': Style(
                              margin: Margins.only(bottom: 4),
                            ),
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    )
                  : const SizedBox(height: 6);
              }(),

              // Иконка папки и статистика
              Row(
                children: [
                  // Иконка папки
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.folder,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Статистика
                  Expanded(
                    child: Row(
                      children: [
                        if (videosCount > 0) ...[
                          _buildFolderStat(Icons.video_library, '$videosCount видео'),
                          if (subfoldersCount > 0) const SizedBox(width: 16),
                        ],
                        if (subfoldersCount > 0) ...[
                          _buildFolderStat(Icons.folder, '$subfoldersCount папок'),
                        ],
                      ],
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

  Widget _buildVideoCard(Video video) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(videoSlug: video.slug),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Миниатюра с длительностью
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: video.thumbnailUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            video.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.play_circle_outline,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 48,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.play_circle_outline,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 48,
                        ),
                ),

                // Длительность
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.formattedDuration,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),


                // Кнопка воспроизведения (декоративная)
                if (video.canWatch)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                // Иконка замка для премиум видео
                if (!video.canWatch)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        color: Theme.of(context).colorScheme.surface,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),

            // Информация о видео
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название видео
                  Text(
                    video.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Автор/канал
                  if (video.videoFolder != null)
                    Text(
                      video.videoFolder!.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 4),

                  // Статистика
                  Row(
                    children: [
                      Text(
                        '${video.viewCount} просмотров',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (video.publishedAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatPublishedDate(video.publishedAt!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Статус премиум
                  if (!video.isFree)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Премиум',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 10,
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
    );
  }

  String _formatPublishedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'сегодня';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д. назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks нед. назад';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months мес. назад';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years г. назад';
    }
  }

  Widget _buildFolderStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }
}
