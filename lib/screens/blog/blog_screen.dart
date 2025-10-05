import 'package:flutter/material.dart';
import 'package:achpp/models/blog.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/services/blog_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';
import 'blog_detail_screen.dart';

class BlogScreen extends StatefulWidget {
  final User? user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;

  const BlogScreen({
    super.key,
    this.user,
    this.subscriptionStatus,
    this.products = const [],
  });

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final BlogService _blogService = BlogService();

  List<Blog> _blogPosts = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  int _lastPage = 1;
  final int _perPage = 15;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadBlogPosts(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBlogPosts({bool reset = false}) async {
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
      final result = await _blogService.getBlogPosts(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: 'published',
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _blogPosts = result.posts;
          } else {
            _blogPosts.addAll(result.posts);
          }
          _lastPage = result.pagination['last_page'] ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки блога: $e');
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
    _loadBlogPosts(reset: true);
  }

  Future<void> _loadMorePosts() async {
    if (_currentPage >= _lastPage || _isLoadingMore) return;

    setState(() {
      _currentPage++;
    });
    await _loadBlogPosts(reset: false);
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
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Блог',
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
      body: SafeArea(
        child: Column(
          children: [
            // Поиск
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Поиск статей...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF2D2D2D),
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
                                  'Ошибка загрузки блога: $_error',
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () => _loadBlogPosts(reset: true),
                                  child: const Text('Повторить'),
                                )
                              ],
                            ),
                          ),
                        )
                      : _blogPosts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B5CF6).withAlpha(51),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.book,
                                      color: Color(0xFF8B5CF6),
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    '📚 Блог',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Ничего не найдено по запросу "$_searchQuery"'
                                        : 'Профессиональные статьи, кейсы,\nметодические материалы и полезные советы\nот экспертов психотерапии',
                                    style: TextStyle(
                                      color: Colors.grey[400],
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
                                        color: const Color(0xFF8B5CF6).withAlpha(51),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF8B5CF6).withAlpha(128),
                                        ),
                                      ),
                                      child: const Text(
                                        '✍️ Экспертные материалы\nКачественный контент для профессионального роста.',
                                        style: TextStyle(
                                          color: Color(0xFF8B5CF6),
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
                                  _loadMorePosts();
                                }
                                return false;
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 10),
                                itemCount: _blogPosts.length + (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _blogPosts.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final post = _blogPosts[index];
                                  return _buildBlogPostCard(post);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogPostCard(Blog post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(
                blog: post,
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
                post.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Категория и дата
              Row(
                children: [
                  if (post.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B46C1).withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        post.category!.name,
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _formatDate(post.publishedAt ?? post.createdAt),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Экстракт
              Text(
                post.excerpt,
                style: TextStyle(
                  color: Colors.grey[300],
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
                  if (post.author != null) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF6B46C1),
                      child: Text(
                        post.author!.fullName.isNotEmpty
                            ? post.author!.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        post.author!.fullName,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.visibility, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        post.viewsCount.toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.thumb_up, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        post.likesCount.toString(),
                        style: const TextStyle(
                          color: Colors.grey,
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
