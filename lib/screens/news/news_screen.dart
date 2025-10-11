import 'package:flutter/material.dart';
import 'package:achpp/models/news.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/services/news_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  final User? user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;

  const NewsScreen({
    super.key,
    this.user,
    this.subscriptionStatus,
    this.products = const [],
  });

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final NewsService _newsService = NewsService();

  List<News> _news = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  int _lastPage = 1;
  final int _perPage = 15;
  bool _isLoadingMore = false;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _loadNews(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final result = await _newsService.getNews(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: 'published',
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _news = result.news;
          } else {
            _news.addAll(result.news);
          }
          _lastPage = result.pagination['last_page'] ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки новостей: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadNews(reset: true);
  }

  Future<void> _loadMoreNews() async {
    if (_currentPage >= _lastPage || _isLoadingMore) return;

    setState(() {
      _currentPage++;
    });
    await _loadNews(reset: false);
  }

  Future<void> _likeNews(String slug, int index) async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final result = await _newsService.likeNews(slug);

      if (mounted) {
        setState(() {
          // Обновляем состояние новости
          final news = _news[index];
          _news[index] = News(
            id: news.id,
            title: news.title,
            slug: news.slug,
            content: news.content,
            excerpt: news.excerpt,
            imageUrl: news.imageUrl,
            type: news.type,
            typeLabel: news.typeLabel,
            priority: news.priority,
            priorityLabel: news.priorityLabel,
            priorityColor: news.priorityColor,
            isFeatured: news.isFeatured,
            isPinned: news.isPinned,
            publishedAt: news.publishedAt,
            formattedPublishedAt: news.formattedPublishedAt,
            author: news.author,
            isOrganizationAuthor: news.isOrganizationAuthor,
            likesCount: result.likesCount,
            dislikesCount: result.dislikesCount,
            isLiked: result.isLiked,
            isDisliked: result.isDisliked,
            viewsCount: news.viewsCount,
            createdAt: news.createdAt,
            updatedAt: news.updatedAt,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при постановке лайка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  Future<void> _dislikeNews(String slug, int index) async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final result = await _newsService.dislikeNews(slug);

      if (mounted) {
        setState(() {
          // Обновляем состояние новости
          final news = _news[index];
          _news[index] = News(
            id: news.id,
            title: news.title,
            slug: news.slug,
            content: news.content,
            excerpt: news.excerpt,
            imageUrl: news.imageUrl,
            type: news.type,
            typeLabel: news.typeLabel,
            priority: news.priority,
            priorityLabel: news.priorityLabel,
            priorityColor: news.priorityColor,
            isFeatured: news.isFeatured,
            isPinned: news.isPinned,
            publishedAt: news.publishedAt,
            formattedPublishedAt: news.formattedPublishedAt,
            author: news.author,
            isOrganizationAuthor: news.isOrganizationAuthor,
            likesCount: result.likesCount,
            dislikesCount: result.dislikesCount,
            isLiked: result.isLiked,
            isDisliked: result.isDisliked,
            viewsCount: news.viewsCount,
            createdAt: news.createdAt,
            updatedAt: news.updatedAt,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при постановке дизлайка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Новости',
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
      body: SafeArea(
        child: Column(
          children: [
            // Поиск
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Поиск новостей...',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Содержимое
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ошибка загрузки новостей: $_error',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () => _loadNews(reset: true),
                                  child: const Text('Повторить'),
                                )
                              ],
                            ),
                          ),
                        )
                      : _news.isEmpty
                          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.article,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '📰 Новости',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Ничего не найдено по запросу "$_searchQuery"'
                                        : 'Здесь будут публиковаться важные новости,\nобновления приложения и анонсы мероприятий',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                                  if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '📢 Следите за обновлениями!\nНовые материалы появляются регулярно.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
                                ],
                              ),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                                  _loadMoreNews();
                                }
                                return false;
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 10),
                                itemCount: _news.length + (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _news.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final newsItem = _news[index];
                                  return _buildNewsCard(newsItem, index);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(News newsItem, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(
                news: newsItem,
                user: widget.user,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Text(
                newsItem.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Тип новости и дата
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      newsItem.typeLabel,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(newsItem.publishedAt ?? newsItem.createdAt),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Экстракт
              Text(
                newsItem.excerpt,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Статистика и автор
              Row(
                children: [
                  // Показываем автора только если это не организация
                  if (newsItem.author != null && !newsItem.isOrganizationAuthor) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: newsItem.author!.avatar != null
                          ? NetworkImage(newsItem.author!.avatar!)
                          : null,
                      child: newsItem.author!.avatar == null
                          ? Text(
                              newsItem.author!.fullName.isNotEmpty
                                  ? newsItem.author!.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        newsItem.author!.fullName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      // Лайки и дизлайки
                      Row(
                        children: [
                          // Лайк
                          InkWell(
                            onTap: () => _likeNews(newsItem.slug, index),
                            child: Row(
                              children: [
                                Icon(
                                  newsItem.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                  color: newsItem.isLiked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 16,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  newsItem.likesCount.toString(),
                                  style: TextStyle(
                                    color: newsItem.isLiked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Дизлайк
                          InkWell(
                            onTap: () => _dislikeNews(newsItem.slug, index),
                            child: Row(
                              children: [
                                Icon(
                                  newsItem.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                                  color: newsItem.isDisliked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 16,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  newsItem.dislikesCount.toString(),
                                  style: TextStyle(
                                    color: newsItem.isDisliked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      // Просмотры
                      Icon(Icons.visibility, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        newsItem.viewsCount.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Комментарии
                      Icon(Icons.chat_bubble_outline, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        newsItem.commentsCount.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д. назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks нед. назад';
    } else {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }
}
