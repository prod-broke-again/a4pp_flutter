import 'package:flutter/material.dart';
import 'package:mobile/models/news.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/subscription.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/models/profile_response.dart';
import 'package:mobile/services/news_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/comments_widget.dart';

class NewsDetailScreen extends StatefulWidget {
  final News news;
  final User? user;

  const NewsDetailScreen({
    super.key,
    required this.news,
    this.user,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late News _currentNews;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _currentNews = widget.news;
  }

  Future<void> _likeNews() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final result = await NewsService().likeNews(_currentNews.slug);

      setState(() {
        _currentNews = News(
          id: _currentNews.id,
          title: _currentNews.title,
          slug: _currentNews.slug,
          content: _currentNews.content,
          excerpt: _currentNews.excerpt,
          imageUrl: _currentNews.imageUrl,
          type: _currentNews.type,
          typeLabel: _currentNews.typeLabel,
          priority: _currentNews.priority,
          priorityLabel: _currentNews.priorityLabel,
          priorityColor: _currentNews.priorityColor,
          isFeatured: _currentNews.isFeatured,
          isPinned: _currentNews.isPinned,
          publishedAt: _currentNews.publishedAt,
          formattedPublishedAt: _currentNews.formattedPublishedAt,
          author: _currentNews.author,
          isOrganizationAuthor: _currentNews.isOrganizationAuthor,
          likesCount: result.likesCount,
          dislikesCount: result.dislikesCount,
          isLiked: result.isLiked,
          isDisliked: result.isDisliked,
          viewsCount: _currentNews.viewsCount,
          createdAt: _currentNews.createdAt,
          updatedAt: _currentNews.updatedAt,
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

  Future<void> _dislikeNews() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final result = await NewsService().dislikeNews(_currentNews.slug);

      setState(() {
        _currentNews = News(
          id: _currentNews.id,
          title: _currentNews.title,
          slug: _currentNews.slug,
          content: _currentNews.content,
          excerpt: _currentNews.excerpt,
          imageUrl: _currentNews.imageUrl,
          type: _currentNews.type,
          typeLabel: _currentNews.typeLabel,
          priority: _currentNews.priority,
          priorityLabel: _currentNews.priorityLabel,
          priorityColor: _currentNews.priorityColor,
          isFeatured: _currentNews.isFeatured,
          isPinned: _currentNews.isPinned,
          publishedAt: _currentNews.publishedAt,
          formattedPublishedAt: _currentNews.formattedPublishedAt,
          author: _currentNews.author,
          isOrganizationAuthor: _currentNews.isOrganizationAuthor,
          likesCount: result.likesCount,
          dislikesCount: result.dislikesCount,
          isLiked: result.isLiked,
          isDisliked: result.isDisliked,
          viewsCount: _currentNews.viewsCount,
          createdAt: _currentNews.createdAt,
          updatedAt: _currentNews.updatedAt,
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
    final news = _currentNews;

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
          'Новость',
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
                news.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Мета информация
              Row(
                children: [
                  // Тип новости
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1).withAlpha(51),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      news.typeLabel,
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Дата публикации
                  Text(
                    _formatDate(news.publishedAt ?? news.createdAt),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Автор (если не организация)
              if (news.author != null && !news.isOrganizationAuthor) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF6B46C1),
                      backgroundImage: news.author!.avatar != null
                          ? NetworkImage(news.author!.avatar!)
                          : null,
                      child: news.author!.avatar == null
                          ? Text(
                              news.author!.fullName.isNotEmpty
                                  ? news.author!.fullName[0].toUpperCase()
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
                      news.author!.fullName,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Изображение (если есть)
              if (news.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    news.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Содержимое новости
              Html(
                data: news.content,
                style: {
                  'body': Style(
                    color: Colors.white,
                    fontSize: FontSize(16),
                    lineHeight: LineHeight.number(1.6),
                  ),
                  'p': Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  'h1': Style(
                    color: Colors.white,
                    fontSize: FontSize(24),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(bottom: 12, top: 20),
                  ),
                  'h2': Style(
                    color: Colors.white,
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(bottom: 12, top: 16),
                  ),
                  'h3': Style(
                    color: Colors.white,
                    fontSize: FontSize(18),
                    fontWeight: FontWeight.w600,
                    margin: Margins.only(bottom: 8, top: 12),
                  ),
                  'ul': Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  'li': Style(
                    color: Colors.white,
                    margin: Margins.only(bottom: 4),
                  ),
                  'a': Style(
                    color: const Color(0xFF8B5CF6),
                    textDecoration: TextDecoration.none,
                  ),
                  'blockquote': Style(
                    backgroundColor: const Color(0xFF2D2D2D),
                    padding: HtmlPaddings.all(16),
                    margin: Margins.only(bottom: 12),
                    border: Border(left: BorderSide(color: const Color(0xFF8B5CF6), width: 4)),
                  ),
                },
              ),

              const SizedBox(height: 24),

              // Статистика и действия
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Просмотры
                    Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${news.viewsCount} просмотров',
                          style: const TextStyle(
                            color: Colors.white,
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
                            onTap: _isLiking ? null : _likeNews,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  news.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                  color: news.isLiked ? Colors.blue : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  news.likesCount.toString(),
                                  style: TextStyle(
                                    color: news.isLiked ? Colors.blue : Colors.grey,
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
                          color: Colors.grey[600],
                        ),

                        // Дизлайк
                        Expanded(
                          child: InkWell(
                            onTap: _isLiking ? null : _dislikeNews,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  news.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                                  color: news.isDisliked ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  news.dislikesCount.toString(),
                                  style: TextStyle(
                                    color: news.isDisliked ? Colors.red : Colors.grey,
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

              const SizedBox(height: 24),

              // Комментарии
              CommentsWidget(
                type: 'news',
                slug: news.slug,
                commentsCount: news.commentsCount,
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
      return '${difference.inDays} д. назад ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks нед. назад';
    } else {
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    }
  }
}
