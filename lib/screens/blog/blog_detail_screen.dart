import 'package:flutter/material.dart';
import 'package:achpp/models/blog.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/services/blog_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/comments_widget.dart';

class BlogDetailScreen extends StatefulWidget {
  final Blog blog;
  final User? user;

  const BlogDetailScreen({
    super.key,
    required this.blog,
    this.user,
  });

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Blog _currentBlog;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _currentBlog = widget.blog;
  }

  Future<void> _likeBlog() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final result = await BlogService().likeBlogPost(_currentBlog.slug);

      setState(() {
        _currentBlog = Blog(
          id: _currentBlog.id,
          title: _currentBlog.title,
          slug: _currentBlog.slug,
          content: _currentBlog.content,
          excerpt: _currentBlog.excerpt,
          thumbnail: _currentBlog.thumbnail,
          status: _currentBlog.status,
          statusLabel: _currentBlog.statusLabel,
          category: _currentBlog.category,
          author: _currentBlog.author,
          publishedAt: _currentBlog.publishedAt,
          metaTitle: _currentBlog.metaTitle,
          metaDescription: _currentBlog.metaDescription,
          viewsCount: _currentBlog.viewsCount,
          likesCount: result.likesCount,
          dislikesCount: result.dislikesCount,
          isLiked: result.isLiked,
          isDisliked: result.isDisliked,
          commentsCount: _currentBlog.commentsCount,
          createdAt: _currentBlog.createdAt,
          updatedAt: _currentBlog.updatedAt,
        );
      });
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

  Future<void> _dislikeBlog() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final result = await BlogService().dislikeBlogPost(_currentBlog.slug);

      setState(() {
        _currentBlog = Blog(
          id: _currentBlog.id,
          title: _currentBlog.title,
          slug: _currentBlog.slug,
          content: _currentBlog.content,
          excerpt: _currentBlog.excerpt,
          thumbnail: _currentBlog.thumbnail,
          status: _currentBlog.status,
          statusLabel: _currentBlog.statusLabel,
          category: _currentBlog.category,
          author: _currentBlog.author,
          publishedAt: _currentBlog.publishedAt,
          metaTitle: _currentBlog.metaTitle,
          metaDescription: _currentBlog.metaDescription,
          viewsCount: _currentBlog.viewsCount,
          likesCount: result.likesCount,
          dislikesCount: result.dislikesCount,
          isLiked: result.isLiked,
          isDisliked: result.isDisliked,
          commentsCount: _currentBlog.commentsCount,
          createdAt: _currentBlog.createdAt,
          updatedAt: _currentBlog.updatedAt,
        );
      });
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
    final blog = _currentBlog;

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
          'Блог',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      drawer: AppDrawer(
        user: null, // TODO: передать пользователя из родительского виджета
        subscriptionStatus: null,
        products: const [],
        currentIndex: 0,
        onIndexChanged: (_) {},
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Text(
                blog.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Мета информация
              Row(
                children: [
                  // Категория
                  if (blog.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        blog.category!.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Дата публикации
                  Text(
                    blog.publishedAt != null ? _formatDate(blog.publishedAt!) : _formatDate(blog.createdAt),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Автор (если есть)
              if (blog.author != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: blog.author!.avatar != null
                          ? NetworkImage(blog.author!.avatar!)
                          : null,
                      child: blog.author!.avatar == null
                          ? Text(
                              blog.author!.fullName.isNotEmpty
                                  ? blog.author!.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      blog.author!.fullName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Изображение (если есть)
              if (blog.thumbnail != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    blog.thumbnail!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Содержимое статьи
              Html(
                data: blog.content,
                style: {
                  'body': Style(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: FontSize(16),
                    lineHeight: LineHeight.number(1.6),
                  ),
                  'p': Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  'h1': Style(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: FontSize(24),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(bottom: 12, top: 20),
                  ),
                  'h2': Style(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(bottom: 12, top: 16),
                  ),
                  'h3': Style(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: FontSize(18),
                    fontWeight: FontWeight.w600,
                    margin: Margins.only(bottom: 8, top: 12),
                  ),
                  'ul': Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  'li': Style(
                    color: Theme.of(context).colorScheme.onSurface,
                    margin: Margins.only(bottom: 4),
                  ),
                  'a': Style(
                    color: Theme.of(context).colorScheme.primary,
                    textDecoration: TextDecoration.none,
                  ),
                  'blockquote': Style(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    padding: HtmlPaddings.all(16),
                    margin: Margins.only(bottom: 12),
                    border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4)),
                  ),
                },
              ),

              const SizedBox(height: 24),

              // Статистика и действия
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Просмотры
                    Row(
                      children: [
                        Icon(Icons.visibility, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${blog.viewsCount} просмотров',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Лайки и дизлайки
                    Row(
                      children: [
                        // Лайк
                        Expanded(
                          child: InkWell(
                            onTap: _isLiking ? null : _likeBlog,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  blog.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                  color: blog.isLiked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  blog.likesCount.toString(),
                                  style: TextStyle(
                                    color: blog.isLiked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Разделитель
                        Container(
                          width: 1,
                          height: 30,
                          color: Theme.of(context).colorScheme.outline,
                        ),

                        // Дизлайк
                        Expanded(
                          child: InkWell(
                            onTap: _isLiking ? null : _dislikeBlog,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  blog.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                                  color: blog.isDisliked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  blog.dislikesCount.toString(),
                                  style: TextStyle(
                                    color: blog.isDisliked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 16,
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
              ),

              // Комментарии
              CommentsWidget(
                type: 'blogs',
                slug: blog.slug,
                commentsCount: blog.commentsCount,
                currentUser: widget.user,
                isAdmin: false, // TODO: передать статус админа
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
      return 'Сегодня ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Вчера ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д. назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks нед. назад';
    } else {
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    }
  }
}
