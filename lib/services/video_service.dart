import 'package:mobile/models/navigation_video.dart';
import 'package:mobile/models/video.dart';
import 'package:mobile/models/video_folder.dart';
import 'package:mobile/repositories/video_repository.dart';

class VideoService {
  final VideoRepository _videoRepository;

  VideoService({VideoRepository? videoRepository})
      : _videoRepository = videoRepository ?? VideoRepository();

  /// Получить все категории видео (корневые папки)
  Future<List<VideoFolder>> getCategories() async {
    final data = await _videoRepository.getVideoCategories();
    final categories = (data['categories'] as List<dynamic>?)
        ?.map((json) => VideoFolder.fromJson(json))
        .toList() ?? [];
    return categories;
  }

  /// Получить видео категории (корневой или подкатегории)
  Future<({
    VideoFolder category,
    List<VideoFolder> subcategories,
    List<Video> videos,
    Map<String, dynamic> pagination,
  })> getCategoryVideos(String categorySlug, {String? search, int page = 1, int perPage = 15}) async {
    final data = await _videoRepository.getVideoCategory(categorySlug, search: search, page: page, perPage: perPage);

    final category = VideoFolder.fromJson(data['category']);
    final subcategories = (data['subcategories'] as List<dynamic>?)
            ?.map((json) => VideoFolder.fromJson(json))
            .toList() 
        ?? [];
    final videos = (data['videos'] as List<dynamic>?)
        ?.map((json) => Video.fromJson(json))
        .toList() ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>;

    return (category: category, subcategories: subcategories, videos: videos, pagination: pagination);
  }

  /// Получить видео с фильтрацией
  Future<({
    List<Video> videos,
    Map<String, dynamic> pagination,
  })> getVideos({String? search, int? videoFolderId, int page = 1, int perPage = 15}) async {
    final data = await _videoRepository.getVideos(search: search, videoFolderId: videoFolderId, page: page, perPage: perPage);

    final videos = (data['videos'] as List<dynamic>?)
        ?.map((json) => Video.fromJson(json))
        .toList() ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>;

    return (videos: videos, pagination: pagination);
  }

  /// Получить конкретное видео
  Future<Video> getVideo(String slug) async {
    final data = await _videoRepository.getVideo(slug);
    return Video.fromJson(data['video']);
  }

  /// Получить навигацию по видео в папке
  Future<({
    List<NavigationVideo> videos,
    int currentVideoId,
    NavigationVideo? previousVideo,
    NavigationVideo? nextVideo,
  })> getVideoNavigation(String slug) async {
    final data = await _videoRepository.getVideoNavigation(slug);

    final videos = (data['videos'] as List<dynamic>)
        .map((json) => NavigationVideo.fromJson(json))
        .toList();

    final currentVideoId = data['current_video_id'] as int;

    // Найти предыдущее и следующее видео
    final currentIndex = videos.indexWhere((v) => v.id == currentVideoId);
    NavigationVideo? previousVideo;
    NavigationVideo? nextVideo;

    if (currentIndex >= 0) {
      // Предыдущее видео (с доступом)
      for (int i = currentIndex - 1; i >= 0; i--) {
        if (videos[i].canWatch) {
          previousVideo = videos[i];
          break;
        }
      }

      // Следующее видео (с доступом)
      for (int i = currentIndex + 1; i < videos.length; i++) {
        if (videos[i].canWatch) {
          nextVideo = videos[i];
          break;
        }
      }
    }

    return (
      videos: videos,
      currentVideoId: currentVideoId,
      previousVideo: previousVideo,
      nextVideo: nextVideo,
    );
  }

  /// Переключить лайк видео
  Future<({
    bool isLiked,
    bool isDisliked,
    int likesCount,
    int dislikesCount,
  })> toggleLike(String slug) async {
    final data = await _videoRepository.toggleVideoLike(slug);
    return (
      isLiked: data['is_liked'] as bool,
      isDisliked: data['is_disliked'] as bool,
      likesCount: data['likes_count'] as int,
      dislikesCount: data['dislikes_count'] as int,
    );
  }

  /// Переключить дизлайк видео
  Future<({
    bool isLiked,
    bool isDisliked,
    int likesCount,
    int dislikesCount,
  })> toggleDislike(String slug) async {
    final data = await _videoRepository.toggleVideoDislike(slug);
    return (
      isLiked: data['is_liked'] as bool,
      isDisliked: data['is_disliked'] as bool,
      likesCount: data['likes_count'] as int,
      dislikesCount: data['dislikes_count'] as int,
    );
  }

  /// Отследить просмотр видео
  Future<int> trackView(String slug) async {
    final data = await _videoRepository.trackVideoView(slug);
    final count = data['view_count'];
    if (count is int) return count;
    // Если API вернул null или иной формат, не падаем
    return 0;
  }

  /// Поиск видео
  Future<({
    List<Video> videos,
    Map<String, dynamic> pagination,
  })> searchVideos(String query, {int page = 1, int perPage = 15}) async {
    return getVideos(search: query, page: page, perPage: perPage);
  }

  /// Получить популярные видео (без фильтров)
  Future<({
    List<Video> videos,
    Map<String, dynamic> pagination,
  })> getPopularVideos({int page = 1, int perPage = 15}) async {
    return getVideos(page: page, perPage: perPage);
  }
}
