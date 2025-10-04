import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/models/navigation_video.dart';
import 'package:mobile/models/video.dart';
import 'package:mobile/models/video_folder.dart';
import 'package:mobile/services/video_service.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_kinescope_sdk/flutter_kinescope_sdk.dart';

// Импорт WebView только для мобильных платформ (fallback)
import 'package:webview_flutter/webview_flutter.dart' show WebViewWidget, WebViewController, JavaScriptMode;

class VideoPlayerScreen extends StatefulWidget {
  final String videoSlug;

  const VideoPlayerScreen({
    super.key,
    required this.videoSlug,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final VideoService _videoService = VideoService();

  Video? _video;
  bool _isLoading = true;
  String? _error;
  bool _canWatch = false;

  // Навигационные видео
  NavigationVideo? _previousVideo;
  NavigationVideo? _nextVideo;
  List<NavigationVideo> _folderVideos = [];
  bool _navigationLoading = false;

  // Плеер
  bool _playerReady = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  bool get _isWebViewSupported => Platform.isAndroid || Platform.isIOS;

  Future<void> _launchUrlDesktop(String url) async {
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', url]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [url]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
      }
    } catch (e) {
      // Если системный вызов не сработал, показываем сообщение
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось открыть браузер: $e')),
        );
      }
    }
  }

  Future<void> _loadVideo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🎬 Загружаем видео: ${widget.videoSlug}');
      final video = await _videoService.getVideo(widget.videoSlug);

      // Проверяем доступ (пока используем простой подход - можно расширить)
      final canWatch = video.canWatch;

      print('✅ Видео загружено: ${video.title}, canWatch: $canWatch');

      setState(() {
        _video = video;
        _canWatch = canWatch;
        _isLoading = false;
      });

      // Загружаем навигацию
      await _loadNavigation();

      // Отслеживаем просмотр
      if (_canWatch) {
        await _trackView();
      }
    } catch (e) {
      print('❌ Ошибка загрузки видео: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNavigation() async {
    if (_video == null) return;

    setState(() {
      _navigationLoading = true;
    });

    try {
      print('🧭 Загружаем навигацию для видео: ${_video!.slug}');
      final result = await _videoService.getVideoNavigation(_video!.slug);

      setState(() {
        _folderVideos = result.videos;
        _previousVideo = result.previousVideo;
        _nextVideo = result.nextVideo;
        _navigationLoading = false;
      });

      print('✅ Навигация загружена: предыдущее=${_previousVideo?.title}, следующее=${_nextVideo?.title}');
    } catch (e) {
      print('❌ Ошибка загрузки навигации: $e');
      setState(() {
        _navigationLoading = false;
      });
    }
  }

  Future<void> _trackView() async {
    if (_video == null) return;

    try {
      await _videoService.trackView(_video!.slug);
      print('👁️ Просмотр отслежен');
    } catch (e) {
      print('⚠️ Не удалось отслеживать просмотр: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (_video == null) return;

    try {
      final result = await _videoService.toggleLike(_video!.slug);

      setState(() {
        _video = _video!.copyWith(
          isLikedByUser: result.isLiked,
          isDislikedByUser: result.isDisliked,
          likesCount: result.likesCount,
          dislikesCount: result.dislikesCount,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка выполнения действия. Попробуйте позже.')),
      );
    }
  }

  Future<void> _toggleDislike() async {
    if (_video == null) return;

    try {
      final result = await _videoService.toggleDislike(_video!.slug);

      setState(() {
        _video = _video!.copyWith(
          isLikedByUser: result.isLiked,
          isDislikedByUser: result.isDisliked,
          likesCount: result.likesCount,
          dislikesCount: result.dislikesCount,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка выполнения действия. Попробуйте позже.')),
      );
    }
  }

  void _navigateToVideo(String slug, {bool isNext = true}) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VideoPlayerScreen(videoSlug: slug),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Для следующего видео: справа налево (1.0 -> 0.0)
          // Для предыдущего видео: слева направо (-1.0 -> 0.0)
          final begin = Offset(isNext ? 1.0 : -1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _loadPlayer() {
    if (_canWatch) {
      setState(() {
        _playerReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(_video?.title ?? 'Видео'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B46C1),
              ),
            )
          : _error != null
              ? _buildErrorView()
              : _canWatch
                  ? _buildVideoPlayerView()
                  : _buildAccessDeniedView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Произошла ошибка',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B46C1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDeniedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Блок с градиентом для ограничения доступа
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.lock,
                  color: Color(0xFFF59E0B),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Доступ ограничен',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Для просмотра этого видео требуется активная подписка',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Миниатюра видео
          if (_video?.thumbnailUrl != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(_video!.thumbnailUrl!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.1),
                    ],
                    begin: Alignment.center,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Информация о видео
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _video?.title ?? 'Без названия',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Мета-информация
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (_video?.videoFolder != null)
                      _buildMetaChip(
                        Icons.folder,
                        _video!.videoFolder!.name,
                      ),
                    if (_video != null)
                      _buildMetaChip(
                        Icons.access_time,
                        _video!.formattedDuration,
                      ),
                    if (_video != null)
                      _buildMetaChip(
                        Icons.visibility,
                        '${_video!.viewCount} просмотров',
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Описание
                if (_video?.description != null &&
                    _video!.description!.trim().isNotEmpty &&
                    _video!.description != '<p></p>' &&
                    _video!.description != '<p>&nbsp;</p>')
                  Html(
                    data: _video!.description!,
                    style: {
                      'body': Style(
                        color: Colors.grey[300],
                        fontSize: FontSize(14),
                        lineHeight: LineHeight.number(1.5),
                      ),
                      'p': Style(
                        margin: Margins.only(bottom: 12),
                      ),
                    },
                  )
                else
                  const Text(
                    'Описание отсутствует',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Призыв к действию
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Получите доступ к видеотеке',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Выберите подходящий тариф и получите доступ ко всем материалам',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Навигация к подписке
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Переход к выбору тарифа')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Выбрать тариф'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Навигационные кнопки
          Row(
            children: [
              if (_previousVideo != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToVideo(_previousVideo!.slug, isNext: false),
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Предыдущее'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              if (_previousVideo != null && _nextVideo != null)
                const SizedBox(width: 16),
              if (_nextVideo != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToVideo(_nextVideo!.slug),
                    icon: const Text('Следующее'),
                    label: const Icon(Icons.chevron_right),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B46C1),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayerView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Видеоплеер (16:9 соотношение)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  // Thumbnail или плеер
                  if (!_playerReady && _video?.thumbnailUrl != null)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_video!.thumbnailUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: IconButton(
                          onPressed: _loadPlayer,
                          icon: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      ),
                    )
                  else if (_video?.videoId != null && _canWatch)
                    KinescopePlayer(
                      controller: KinescopePlayerController(
                        _video!.videoId!,
                        parameters: const PlayerParameters(
                          autoplay: false,
                          muted: true,
                        ),
                      ),
                      aspectRatio: 16 / 9,
                    )
                  else if (_video?.videoUrl != null && _canWatch)
                    _isWebViewSupported
                        ? WebViewWidget(
                            controller: WebViewController()
                              ..setJavaScriptMode(JavaScriptMode.unrestricted)
                              ..setBackgroundColor(Colors.black)
                              ..loadRequest(Uri.parse(_video!.videoUrl!)),
                          )
                        : Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Видео недоступно на этой платформе',
                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      if (_video?.videoUrl != null) {
                                        try {
                                          final url = Uri.parse(_video!.videoUrl!);
                                          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                                            // Для desktop платформ используем другой подход
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('URL скопирован: ${_video!.videoUrl}'),
                                                action: SnackBarAction(
                                                  label: 'Открыть',
                                                  onPressed: () {
                                                    // Попробовать открыть через системный вызов
                                                    _launchUrlDesktop(_video!.videoUrl!);
                                                  },
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Для мобильных платформ
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            }
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Ошибка выполнения действия. Попробуйте позже.')),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.open_in_browser),
                                    label: const Text('Открыть видео'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6B46C1),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                  else if (_video?.videoUrl != null && !_canWatch)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Требуется подписка',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Text(
                        'Видео недоступно',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  // Кнопки навигации
                  if (_previousVideo != null)
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          onPressed: () => _navigateToVideo(_previousVideo!.slug, isNext: false),
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 32,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),

                  if (_nextVideo != null)
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          onPressed: () => _navigateToVideo(_nextVideo!.slug),
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 32,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Информация о видео
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Text(
                  _video?.title ?? 'Без названия',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Мета-информация
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (_video?.videoFolder != null)
                      _buildMetaChip(
                        Icons.folder,
                        _video!.videoFolder!.name,
                      ),
                    if (_video != null)
                      _buildMetaChip(
                        Icons.access_time,
                        _video!.formattedDuration,
                      ),
                    if (_video != null)
                      _buildMetaChip(
                        Icons.visibility,
                        '${_video!.viewCount} просмотров',
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Описание
                if (_video?.description != null &&
                    _video!.description!.trim().isNotEmpty &&
                    _video!.description != '<p></p>' &&
                    _video!.description != '<p>&nbsp;</p>')
                  Html(
                    data: _video!.description!,
                    style: {
                      'body': Style(
                        color: Colors.grey[300],
                        fontSize: FontSize(16),
                        lineHeight: LineHeight.number(1.6),
                      ),
                      'p': Style(
                        margin: Margins.only(bottom: 16),
                      ),
                    },
                  )
                else
                  const Text(
                    'Описание отсутствует',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                const SizedBox(height: 32),

                // Действия с видео
                Row(
                  children: [
                    // Лайк
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleLike,
                        icon: Icon(
                          _video?.isLikedByUser == true ? Icons.favorite : Icons.favorite_border,
                          color: _video?.isLikedByUser == true ? Colors.red : Colors.white,
                        ),
                        label: Text('${_video?.likesCount ?? 0}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D2D2D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Дизлайк
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleDislike,
                        icon: Icon(
                          _video?.isDislikedByUser == true ? Icons.thumb_down : Icons.thumb_down_outlined,
                          color: _video?.isDislikedByUser == true ? Colors.blue : Colors.white,
                        ),
                        label: Text('${_video?.dislikesCount ?? 0}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D2D2D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Навигация между видео
                Row(
                  children: [
                    if (_previousVideo != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _navigateToVideo(_previousVideo!.slug, isNext: false),
                          icon: const Icon(Icons.chevron_left),
                          label: const Text('Предыдущее'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    if (_previousVideo != null && _nextVideo != null)
                      const SizedBox(width: 16),
                    if (_nextVideo != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToVideo(_nextVideo!.slug),
                          label: const Text('Следующее'),
                          icon: const Icon(Icons.chevron_right),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6B46C1), size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

}

// Extension для копирования Video с изменениями
extension VideoCopyWith on Video {
  Video copyWith({
    int? id,
    String? title,
    String? slug,
    String? description,
    String? videoUrl,
    String? videoId,
    String? thumbnailUrl,
    int? durationMinutes,
    int? actualDuration,
    String? formattedDuration,
    int? viewCount,
    bool? isFree,
    bool? canWatch,
    VideoFolder? videoFolder,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? dislikesCount,
    bool? isLikedByUser,
    bool? isDislikedByUser,
    String? status,
    int? sortOrder,
    List<String>? tags,
    String? notes,
    String? metaTitle,
    String? metaDescription,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      videoId: videoId ?? this.videoId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      actualDuration: actualDuration ?? this.actualDuration,
      formattedDuration: formattedDuration ?? this.formattedDuration,
      viewCount: viewCount ?? this.viewCount,
      isFree: isFree ?? this.isFree,
      canWatch: canWatch ?? this.canWatch,
      videoFolder: videoFolder ?? this.videoFolder,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      isDislikedByUser: isDislikedByUser ?? this.isDislikedByUser,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
    );
  }
}
