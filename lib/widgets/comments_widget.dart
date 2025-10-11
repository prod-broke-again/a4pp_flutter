import 'package:flutter/material.dart';
import 'package:achpp/models/comment.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/services/comment_service.dart';
import 'package:intl/intl.dart';

// Комментарии теперь полностью поддерживают светлую и темную темы

enum CommentSort { newest, oldest, popular }

class CommentsWidget extends StatefulWidget {
  final String type; // 'news', 'blog', 'meetings' etc.
  final String slug;
  final int commentsCount;
  final User? currentUser;
  final bool isAdmin;

  const CommentsWidget({
    super.key,
    required this.type,
    required this.slug,
    required this.commentsCount,
    this.currentUser,
    this.isAdmin = false,
  });

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> with TickerProviderStateMixin {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _replyFocusNode = FocusNode();

  // Получить текущего пользователя
  User? get _currentUser => widget.currentUser;

  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSubmitting = false;
  String? _error;
  CommentSort _sortBy = CommentSort.newest;

  int _currentPage = 1;
  int _lastPage = 1;
  final int _perPage = 15;

  // Для ответов на комментарии
  Comment? _replyingToComment;
  bool _isReplying = false;

  // Для скролла
  final ScrollController _scrollController = ScrollController();

  // Анимации
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadComments();

    // Инициализация анимаций
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _commentFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    _commentFocusNode.dispose();
    _replyFocusNode.dispose();
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_commentFocusNode.hasFocus && !_fadeAnimationController.isCompleted) {
      _fadeAnimationController.forward();
    }
  }

  Future<void> _loadComments({bool reset = false}) async {
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
      final result = await _commentService.getComments(
        widget.type,
        widget.slug,
        page: _currentPage,
        perPage: _perPage,
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _comments = result.comments;
          } else {
            _comments.addAll(result.comments);
          }
          _lastPage = result.pagination['last_page'] ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreComments() async {
    if (_currentPage >= _lastPage || _isLoadingMore) return;

    setState(() {
      _currentPage++;
    });
    await _loadComments();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newComment = await _commentService.addComment(widget.type, widget.slug, content);

      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
          _commentController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Комментарий добавлен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _submitReply(int commentId) async {
    final content = _replyController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isReplying = true;
    });

    try {
      final reply = await _commentService.replyToComment(widget.type, widget.slug, commentId, content);

      if (mounted) {
        setState(() {
          // Найдем родительский комментарий и добавим ответ
          final commentIndex = _comments.indexWhere((c) => c.id == commentId);
          if (commentIndex != -1) {
            final comment = _comments[commentIndex];
            final updatedComment = Comment(
              id: comment.id,
              content: comment.content,
              status: comment.status,
              user: comment.user,
              likesCount: comment.likesCount,
              isLiked: comment.isLiked,
              replies: [...(comment.replies ?? []), reply],
              createdAt: comment.createdAt,
            );
            _comments[commentIndex] = updatedComment;
          }
          _replyController.clear();
          _replyingToComment = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ответ добавлен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReplying = false;
        });
      }
    }
  }

  Future<void> _toggleCommentLike(int commentId) async {
    try {
      final data = await _commentService.toggleCommentLike(commentId);

      if (!mounted) return;
      setState(() {
        _applyLikeResponseToComment(commentId, data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _applyLikeResponseToComment(int commentId, Map<String, dynamic> data) {
    final bool newIsLiked = (data['is_liked'] as bool?) ?? false;
    final int newLikesCount = (data['likes_count'] as int?) ?? 0;

    for (var i = 0; i < _comments.length; i++) {
      if (_comments[i].id == commentId) {
        final comment = _comments[i];
        _comments[i] = Comment(
          id: comment.id,
          content: comment.content,
          status: comment.status,
          user: comment.user,
          likesCount: newLikesCount,
          isLiked: newIsLiked,
          replies: comment.replies,
          createdAt: comment.createdAt,
        );
        return;
      }

      final replies = _comments[i].replies;
      if (replies != null && replies.isNotEmpty) {
        for (var j = 0; j < replies.length; j++) {
          final reply = replies[j];
          if (reply.id == commentId) {
            final updatedReplies = List<Comment>.from(replies);
            updatedReplies[j] = Comment(
              id: reply.id,
              content: reply.content,
              status: reply.status,
              user: reply.user,
              likesCount: newLikesCount,
              isLiked: newIsLiked,
              replies: reply.replies,
              createdAt: reply.createdAt,
            );

            _comments[i] = Comment(
              id: _comments[i].id,
              content: _comments[i].content,
              status: _comments[i].status,
              user: _comments[i].user,
              likesCount: _comments[i].likesCount,
              isLiked: _comments[i].isLiked,
              replies: updatedReplies,
              createdAt: _comments[i].createdAt,
            );
            return;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedComments = _getSortedComments();

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с количеством комментариев и сортировкой
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.comment, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  '${widget.commentsCount} ${_getCommentsText(widget.commentsCount)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_comments.isNotEmpty) ...[
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Сортировка комментариев',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: Icon(
                                    _sortBy == CommentSort.newest ? Icons.check : null,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  title: Text(
                                    'Сначала новые',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _sortBy = CommentSort.newest;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    _sortBy == CommentSort.oldest ? Icons.check : null,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  title: Text(
                                    'Сначала старые',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _sortBy = CommentSort.oldest;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    _sortBy == CommentSort.popular ? Icons.check : null,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  title: Text(
                                    'По популярности',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _sortBy = CommentSort.popular;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.sort,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    tooltip: 'Сортировка',
                  ),
                ],
              ],
            ),
          ),

          // Форма добавления комментария
          _buildCommentForm(),

          // Список комментариев
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Ошибка загрузки комментариев: $_error',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _loadComments(reset: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            )
          else if (sortedComments.isEmpty)
            _buildEmptyState()
          else
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  _loadMoreComments();
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedComments.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == sortedComments.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final comment = sortedComments[index];
                  return _buildCommentItem(comment);
                },
              ),
            ),
        ],
      ),
    );
  }

  List<Comment> _getSortedComments() {
    final comments = List<Comment>.from(_comments);

    switch (_sortBy) {
      case CommentSort.oldest:
        comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case CommentSort.popular:
        comments.sort((a, b) => (b.likesCount).compareTo(a.likesCount));
        break;
      case CommentSort.newest:
        comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return comments;
  }

  String _getCommentsText(int count) {
    if (count == 0) return 'комментариев';
    if (count == 1) return 'комментарий';
    if (count >= 2 && count <= 4) return 'комментария';
    return 'комментариев';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B); // amber-500
      case 'approved':
        return const Color(0xFF10B981); // emerald-500
      case 'rejected':
        return const Color(0xFFEF4444); // red-500
      default:
        return const Color(0xFF6B7280); // gray-500
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'На модерации';
      case 'approved':
        return 'Одобрен';
      case 'rejected':
        return 'Отклонен';
      default:
        return 'Неизвестно';
    }
  }

  Widget _buildCommentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватар пользователя
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: _currentUser?.avatar != null
                  ? NetworkImage(_currentUser!.avatar!)
                  : null,
              child: _currentUser?.avatar == null
                  ? Text(
                      _currentUser?.fullName.isNotEmpty == true
                          ? _currentUser!.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),

          // Форма ввода
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  maxLines: _commentFocusNode.hasFocus ? 4 : 1,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Поделитесь своими мыслями...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),

                // Подсказка и счетчик символов
                if (_commentController.text.isNotEmpty || _commentFocusNode.hasFocus)
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Комментарий будет опубликован после проверки модератором',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                '${_commentController.text.length}/2000',
                                style: TextStyle(
                                  color: _commentController.text.length > 2000
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // Кнопки действий
                if (_commentController.text.isNotEmpty || _commentFocusNode.hasFocus)
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_commentController.text.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    _commentController.clear();
                                    setState(() {});
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Очистить', style: TextStyle(fontSize: 14)),
                                ),
                              const SizedBox(width: 4),
                              ElevatedButton(
                                onPressed: _isSubmitting ||
                                    _commentController.text.trim().isEmpty ||
                                    _commentController.text.length > 2000
                                    ? null
                                    : _submitComment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Text('Отправить', style: TextStyle(fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.forum_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Пока нет комментариев',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Станьте первым, кто оставит комментарий!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Автор, дата и статус модерации
            Row(
              children: [
                // Аватар
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: comment.user?.avatar != null
                      ? NetworkImage(comment.user!.avatar!)
                      : null,
                  child: comment.user?.avatar == null
                      ? Text(
                          comment.user?.fullName.isNotEmpty == true
                              ? comment.user!.fullName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Информация об авторе
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user?.fullName ?? 'Пользователь',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Статус модерации (для админов)
                if (widget.isAdmin) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(comment.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(comment.status),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Текст комментария
            Text(
              comment.content,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // Действия
            Row(
              children: [
                // Лайк
                InkWell(
                  onTap: () => _toggleCommentLike(comment.id),
                  child: Row(
                    children: [
                      Icon(
                        comment.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: comment.isLiked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        comment.likesCount.toString(),
                        style: TextStyle(
                          color: comment.isLiked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Ответить
                InkWell(
                  onTap: () {
                    setState(() {
                      _replyingToComment = _replyingToComment == comment ? null : comment;
                      if (_replyingToComment == comment) {
                        // Не очищаем контроллер здесь, только при успешной отправке
                        // Фокус на поле ответа через небольшую задержку
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _replyFocusNode.requestFocus();
                        });
                      } else {
                        // Если закрываем форму ответа, очищаем контроллер
                        _replyController.clear();
                      }
                    });
                  },
                  child:                   Text(
                    'Ответить',
                    style: TextStyle(
                      color: _replyingToComment == comment ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // Форма ответа
            if (_replyingToComment == comment) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Аватар текущего пользователя
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          backgroundImage: _currentUser?.avatar != null
                              ? NetworkImage(_currentUser!.avatar!)
                              : null,
                          child: _currentUser?.avatar == null
                              ? Text(
                                  _currentUser?.fullName.isNotEmpty == true
                                      ? _currentUser!.fullName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            focusNode: _replyFocusNode,
                            maxLines: 3,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Напишите ответ...',
                              hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _replyingToComment = null;
                              _replyController.clear();
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          child: const Text('Отмена'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isReplying || _replyController.text.trim().isEmpty || _replyController.text.length > 2000
                              ? null
                              : () => _submitReply(comment.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: _isReplying
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : const Text('Ответить'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Ответы
            if (comment.replies != null && comment.replies!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: comment.replies!.map((reply) => _buildReplyItem(reply)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyItem(Comment reply) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(top: 12, left: 32),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
            right: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
            bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
            left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Автор и дата ответа
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: reply.user?.avatar != null
                      ? NetworkImage(reply.user!.avatar!)
                      : null,
                  child: reply.user?.avatar == null
                      ? Text(
                          reply.user?.fullName.isNotEmpty == true
                              ? reply.user!.fullName[0].toUpperCase()
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.user?.fullName ?? 'Пользователь',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(reply.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Статус для админов
                if (widget.isAdmin) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(reply.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(reply.status),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Содержимое ответа
            Text(
              reply.content,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 8),

            // Лайк для ответа
            InkWell(
              onTap: () => _toggleCommentLike(reply.id),
              child: Row(
                children: [
                  Icon(
                    reply.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: reply.isLiked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reply.likesCount.toString(),
                    style: TextStyle(
                      color: reply.isLiked ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Вчера ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д. назад';
    } else {
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    }
  }
}
