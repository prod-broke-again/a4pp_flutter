import 'package:achpp/models/user.dart';
import 'package:achpp/models/subscription.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/news.dart';
import 'package:achpp/models/video.dart';
import 'package:achpp/models/meeting.dart';
import 'package:achpp/models/club.dart';
import 'package:achpp/models/course.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/repositories/auth_repository.dart';
import 'package:achpp/repositories/news_repository.dart';
import 'package:achpp/repositories/video_repository.dart';
import 'package:achpp/repositories/meeting_repository.dart';

/// Сервис для предварительной загрузки данных главной страницы
class PreloadService {
  final AuthRepository _authRepository = AuthRepository();
  final NewsRepository _newsRepository = NewsRepository();
  final VideoRepository _videoRepository = VideoRepository();
  final MeetingRepository _meetingRepository = MeetingRepository();

  /// Предзагруженные данные для главной страницы
  static PreloadedData? _cachedData;

  /// Получить кэшированные данные (если есть)
  static PreloadedData? getCachedData() => _cachedData;

  /// Очистить кэш
  static void clearCache() => _cachedData = null;

  /// Предварительная загрузка всех данных для главной страницы
  Future<PreloadedData> preloadHomeData() async {
    print('🚀 Начинаем предварительную загрузку данных главной страницы...');

    try {
      // Загружаем все данные параллельно для максимальной скорости
      final results = await Future.wait([
        _authRepository.getProfile(),
        _authRepository.getCurrentSubscription(),
        _authRepository.getFavorites(),
        _authRepository.getNotifications(perPage: 5),
        _newsRepository.getFeaturedNews(limit: 1),
        _videoRepository.getLatestVideo(),
        _authRepository.getWatchHistory(limit: 3),
        _meetingRepository.getUpcomingMeetings(limit: 3),
      ]);

      // Парсим результаты
      final profileData = results[0] as ProfileData;
      final subscriptionData = results[1] as Map<String, dynamic>;
      final favoritesData = results[2] as Map<String, dynamic>;
      final notificationsData = results[3] as Map<String, dynamic>;
      final newsData = results[4] as Map<String, dynamic>;
      final videoData = results[5] as Map<String, dynamic>;
      final watchHistoryData = results[6] as Map<String, dynamic>;
      final meetingsData = results[7] as Map<String, dynamic>;

      // Создаем объект с предзагруженными данными
      final preloadedData = PreloadedData(
        profileData: profileData,
        subscriptionData: subscriptionData,
        favoritesData: favoritesData,
        notificationsData: notificationsData,
        newsData: newsData,
        videoData: videoData,
        watchHistoryData: watchHistoryData,
        meetingsData: meetingsData,
        timestamp: DateTime.now(),
      );

      // Кэшируем данные
      _cachedData = preloadedData;

      print('✅ Предварительная загрузка данных завершена успешно');
      return preloadedData;

    } catch (e) {
      print('❌ Ошибка предварительной загрузки: $e');
      // В случае ошибки возвращаем пустые данные, чтобы приложение продолжило работу
      return PreloadedData.empty();
    }
  }
}

/// Класс для хранения предзагруженных данных
class PreloadedData {
  final ProfileData? profileData;
  final Map<String, dynamic>? subscriptionData;
  final Map<String, dynamic>? favoritesData;
  final Map<String, dynamic>? notificationsData;
  final Map<String, dynamic>? newsData;
  final Map<String, dynamic>? videoData;
  final Map<String, dynamic>? watchHistoryData;
  final Map<String, dynamic>? meetingsData;
  final DateTime timestamp;

  PreloadedData({
    required this.profileData,
    required this.subscriptionData,
    required this.favoritesData,
    required this.notificationsData,
    required this.newsData,
    required this.videoData,
    required this.watchHistoryData,
    required this.meetingsData,
    required this.timestamp,
  });

  /// Создает пустой объект с данными по умолчанию
  factory PreloadedData.empty() {
    return PreloadedData(
      profileData: null,
      subscriptionData: {'subscription': null, 'expires_at': null},
      favoritesData: {'favorites': []},
      notificationsData: {'notifications': [], 'unread_count': 0},
      newsData: {'news': []},
      videoData: {'video': null},
      watchHistoryData: {'videos': []},
      meetingsData: {'meetings': []},
      timestamp: DateTime.now(),
    );
  }

  /// Проверяет, устарели ли данные (более 5 минут)
  bool get isExpired {
    return DateTime.now().difference(timestamp).inMinutes > 5;
  }

  /// Проверяет, что основные данные загружены
  bool get isComplete {
    return profileData != null &&
           subscriptionData != null &&
           favoritesData != null;
  }
}
