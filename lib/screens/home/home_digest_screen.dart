import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/subscription.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/news.dart';
import 'package:achpp/models/video.dart';
import 'package:achpp/models/meeting.dart';
import 'package:achpp/models/club.dart';
import 'package:achpp/models/course.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/services/preload_service.dart';
import 'package:achpp/repositories/auth_repository.dart';
import 'package:achpp/repositories/news_repository.dart';
import 'package:achpp/repositories/video_repository.dart';
import 'package:achpp/repositories/meeting_repository.dart';

class HomeDigestScreen extends StatefulWidget {
  final User? user;
  final Subscription? subscription;
  final List<Product> products;
  final PreloadedData? preloadedData;

  const HomeDigestScreen({
    super.key,
    this.user,
    this.subscription,
    this.products = const [],
    this.preloadedData,
  });

  @override
  State<HomeDigestScreen> createState() => _HomeDigestScreenState();
}

class _HomeDigestScreenState extends State<HomeDigestScreen> {
  bool _isLoading = true;
  bool _isPremium = false;

  // Repositories
  final AuthRepository _authRepository = AuthRepository();
  final NewsRepository _newsRepository = NewsRepository();
  final VideoRepository _videoRepository = VideoRepository();
  final MeetingRepository _meetingRepository = MeetingRepository();
  
  // Data
  late News _latestNews;
  late Video _latestVideo;
  late Video _continueWatchingVideo;
  late Meeting _nextMeeting;
  late List<Club> _favoriteClubs;
  late List<Course> _favoriteCourses;
  late List<Meeting> _upcomingMeetings;
  late List<News> _recentNews;
  late List<Video> _continueWatchingList;
  late Map<int, Map<String, dynamic>> _videoProgress; // video_id -> progress data
  String? _unreadNotification;

  @override
  void initState() {
    super.initState();
    _initializeWithPreloadedData();
  }

  /// Инициализация с предварительно загруженными данными или загрузка с API
  void _initializeWithPreloadedData() {
    if (widget.preloadedData != null && widget.preloadedData!.isComplete && !widget.preloadedData!.isExpired) {
      print('✅ HomeDigestScreen: используем предварительно загруженные данные');
      _initializeFromPreloadedData(widget.preloadedData!);
    } else {
      print('🔄 HomeDigestScreen: предзагруженные данные недоступны, загружаем с API');
      _loadRealData();
    }
  }

  /// Инициализация состояния из предварительно загруженных данных
  void _initializeFromPreloadedData(PreloadedData data) {
    try {
      setState(() {
        _isLoading = false;

        // Парсим профиль
        final profileData = data.profileData!;
        // Проверка премиум статуса будет выполнена из данных подписки ниже

        // Парсим текущую подписку
        final subscriptionData = data.subscriptionData!;
        final subscription = subscriptionData['subscription'];
        if (subscription != null) {
          _isPremium = subscription['status'] == 'active';
        }

        // Парсим избранное
        final favoritesData = data.favoritesData!;
        final favorites = _safeGetList(favoritesData, 'favorites');
        print('📋 HomeDigest: загружено избранных элементов: ${favorites.length}');
        _initializeFavoritesFromApi(favorites);

        // Парсим уведомления
        final notificationsData = data.notificationsData!;
        final notifications = _safeGetList(notificationsData, 'notifications');
        final unreadNotifications = notifications.where((n) => n['read_at'] == null).toList();
        if (unreadNotifications.isNotEmpty) {
          _unreadNotification = unreadNotifications.first['message'] as String?;
        }

        // Парсим последние новости
        final newsData = data.newsData!;
        final newsList = _safeGetList(newsData, 'news');
        if (newsList.isNotEmpty) {
          _latestNews = News.fromJson(newsList.first);
        } else {
          // Fallback новость если данные не загружены
          _latestNews = News(
            id: 1,
            title: 'Новости скоро появятся',
            slug: 'no-news',
            content: 'Новости АЧПП скоро будут доступны',
            excerpt: 'Следите за обновлениями',
            imageUrl: null,
            type: 'news',
            typeLabel: 'Новость',
            priority: 'normal',
            priorityLabel: 'Обычный',
            priorityColor: '#6B7280',
            isFeatured: false,
            isPinned: false,
            publishedAt: DateTime.now(),
            formattedPublishedAt: null,
            author: null,
            isOrganizationAuthor: false,
            likesCount: 0,
            dislikesCount: 0,
            isLiked: false,
            isDisliked: false,
            viewsCount: 0,
            commentsCount: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        // Парсим последнее видео
        final videoData = data.videoData!;
        if (videoData['video'] != null) {
          _latestVideo = Video.fromJson(videoData['video']);
        } else {
          // Fallback видео если данные не загружены
          _latestVideo = Video(
            id: 1,
            title: 'Видео скоро появится',
            slug: 'no-video',
            description: 'Следите за обновлениями',
            videoUrl: null,
            videoId: null,
            thumbnailUrl: null,
            durationMinutes: 0,
            actualDuration: 0,
            formattedDuration: '00:00',
            viewCount: 0,
            isFree: true,
            canWatch: true,
            videoFolder: null,
            publishedAt: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            likesCount: 0,
            dislikesCount: 0,
            isLikedByUser: false,
            isDislikedByUser: false,
            status: 'draft',
            sortOrder: 0,
            tags: const [],
            notes: null,
            metaTitle: null,
            metaDescription: null,
          );
        }

        // Парсим историю просмотров
        final watchHistoryData = data.watchHistoryData!;
        final videosList = _safeGetList(watchHistoryData, 'videos');
        _continueWatchingList = videosList.map((v) => Video.fromJson(v)).toList();
        if (_continueWatchingList.isNotEmpty) {
          _continueWatchingVideo = _continueWatchingList.first;
        } else {
          // Fallback видео для продолжения просмотра
          _continueWatchingVideo = _latestVideo;
        }

        // Инициализируем прогресс видео
        _videoProgress = {};

        // Парсим предстоящие встречи
        final meetingsData = data.meetingsData!;
        final meetingsList = _safeGetList(meetingsData, 'meetings');
        _upcomingMeetings = meetingsList.map((m) => Meeting.fromJson(m)).toList();
        if (_upcomingMeetings.isNotEmpty) {
          _nextMeeting = _upcomingMeetings.first;
        } else {
          // Fallback встреча если данные не загружены
          _nextMeeting = Meeting(
            id: 1,
            name: 'Встречи скоро появятся',
            slug: 'no-meetings',
            description: 'Следите за обновлениями АЧПП',
            image: null,
            date: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            formattedDate: 'Через неделю',
            startTime: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            endTime: DateTime.now().add(const Duration(days: 7, hours: 1)).toIso8601String(),
            formattedStartTime: '10:00',
            formattedEndTime: '11:00',
            duration: '1 час',
            format: 'online',
            formatLabel: 'Онлайн',
            platform: 'Zoom',
            joinUrl: null,
            location: null,
            maxParticipants: 100,
            status: 'upcoming',
            statusLabel: 'Предстоящая',
            notes: null,
            organizer: null,
            category: null,
            participantsCount: 0,
            commentsCount: 0,
            isUpcoming: true,
            isPast: false,
            isToday: false,
            isOrganizer: false,
            isFavoritedByUser: false,
            likesCount: 0,
            isLiked: false,
            speakers: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        // Инициализируем список последних новостей (пустой, так как у нас только одна последняя новость)
        _recentNews = [];

        // Инициализируем fallback данные для полей, которые могут быть пустыми
        _initializeFallbackData();
      });

      print('✅ HomeDigestScreen: данные успешно инициализированы из предзагрузки');

    } catch (e) {
      print('❌ HomeDigestScreen: ошибка инициализации предзагруженных данных: $e');
      // В случае ошибки переходим к обычной загрузке
      _loadRealData();
    }
  }

  Future<void> _loadRealData() async {
    try {
      // Загружаем все данные параллельно
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

      if (mounted) {
        setState(() {
          _isLoading = false;

          // Парсим профиль
          results[0] as ProfileData;

          // Парсим текущую подписку
          final subscriptionData = results[1] as Map<String, dynamic>;
          final subscription = subscriptionData['subscription'];
          _isPremium = subscription != null && subscription['status'] == 'active';

          // Парсим избранное
          final favoritesData = results[2] as Map<String, dynamic>;
          final favorites = _safeGetList(favoritesData, 'favorites');
          print('📋 Загружено избранных элементов: ${favorites.length}');
          _initializeFavoritesFromApi(favorites);

          // Парсим уведомления
          final notificationsData = results[3] as Map<String, dynamic>;
          final notifications = _safeGetList(notificationsData, 'notifications');
          final unreadNotifications = notifications.where((n) => n['read_at'] == null).toList();
          if (unreadNotifications.isNotEmpty) {
            _unreadNotification = unreadNotifications.first['message'] as String?;
          }

          // Парсим новости
          final newsData = results[4] as Map<String, dynamic>;
          final newsList = _safeGetList(newsData, 'news');
          if (newsList.isNotEmpty) {
            _latestNews = News.fromJson(newsList.first as Map<String, dynamic>);
          } else {
            _initializeFallbackNews();
          }

          // Парсим видео
          final latestVideoData = results[5] as Map<String, dynamic>;
          final videosList = _safeGetList(latestVideoData, 'videos');
          if (videosList.isNotEmpty) {
            _latestVideo = Video.fromJson(videosList.first as Map<String, dynamic>);
          } else {
            _initializeFallbackVideo();
          }

          // Парсим видео для продолжения (история просмотров)
          final continueWatchingData = results[6] as Map<String, dynamic>;
          final continueVideosList = _safeGetList(continueWatchingData, 'videos');
          _continueWatchingList = [];
          _videoProgress = {};

          for (final videoData in continueVideosList) {
            final video = Video.fromJson(videoData as Map<String, dynamic>);
            _continueWatchingList.add(video);

            // Сохраняем информацию о прогрессе
            if (videoData.containsKey('progress_seconds')) {
              _videoProgress[video.id] = {
                'progress_seconds': videoData['progress_seconds'] ?? 0,
                'completed': videoData['completed'] ?? false,
                'progress_percentage': videoData['progress_percentage'] ?? 0.0,
                'last_watched_at': videoData['last_watched_at'],
              };
            }
          }

          // Парсим встречи
          final meetingsData = results[7] as Map<String, dynamic>;
          final meetingsList = _safeGetList(meetingsData, 'meetings');
          _upcomingMeetings = meetingsList
              .map((meeting) => Meeting.fromJson(meeting as Map<String, dynamic>))
              .toList();

          // Инициализируем fallback данные если что-то не загрузилось
          _initializeFallbackData();
        });
      }
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      // В случае ошибки используем mock данные
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPremium = widget.subscription?.status == 'active';
          _initializeMockData();
        });
      }
    }
  }

  void _initializeMockData() {
    // Mock latest news
    _latestNews = News(
      id: 1,
      title: 'Новые изменения в платформе АЧПП',
      slug: 'new-platform-changes',
      content: 'Полное содержание новости...',
      excerpt: 'Мы рады сообщить о важных обновлениях в нашей платформе...',
      imageUrl: null,
      type: 'announcement',
      typeLabel: 'Объявление',
      priority: 'high',
      priorityLabel: 'Высокий',
      priorityColor: '#EF4444',
      isFeatured: true,
      isPinned: false,
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      formattedPublishedAt: '2 часа назад',
      author: widget.user,
      isOrganizationAuthor: true,
      likesCount: 15,
      dislikesCount: 0,
      isLiked: false,
      isDisliked: false,
      viewsCount: 234,
      commentsCount: 8,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    // Mock latest video
    _latestVideo = Video(
      id: 1,
      title: 'Работа с тревожными расстройствами',
      slug: 'anxiety-disorders-treatment',
      description: 'Подробный разбор методов работы с тревожными расстройствами',
      videoUrl: 'https://example.com/video1.mp4',
      videoId: 'video1',
      thumbnailUrl: null,
      durationMinutes: 45,
      actualDuration: 2700,
      formattedDuration: '45 мин',
      viewCount: 156,
      isFree: false,
      canWatch: _isPremium,
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    );

    // Mock continue watching video
    _continueWatchingVideo = Video(
      id: 2,
      title: 'Когнитивно-поведенческая терапия',
      slug: 'cbt-therapy',
      description: 'Основы КПТ для практикующих психологов',
      videoUrl: 'https://example.com/video2.mp4',
      videoId: 'video2',
      thumbnailUrl: null,
      durationMinutes: 60,
      actualDuration: 3600,
      formattedDuration: '1 ч',
      viewCount: 89,
      isFree: false,
      canWatch: _isPremium,
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    );

    // Mock next meeting
    _nextMeeting = Meeting(
      id: 1,
      name: 'Разбор клинических случаев',
      slug: 'clinical-cases-review',
      description: 'Еженедельная встреча для разбора сложных случаев',
      image: null,
      date: DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      formattedDate: 'Сегодня',
      startTime: DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      endTime: DateTime.now().add(const Duration(hours: 3)).toIso8601String(),
      formattedStartTime: '19:00',
      formattedEndTime: '20:00',
      duration: '1 час',
      format: 'online',
      formatLabel: 'Онлайн',
      platform: 'Zoom',
      joinUrl: _isPremium ? 'https://zoom.us/j/123456789' : null,
      location: null,
      maxParticipants: 50,
      status: 'upcoming',
      statusLabel: 'Предстоящая',
      organizer: widget.user,
      participantsCount: 23,
      commentsCount: 5,
      isUpcoming: true,
      isPast: false,
      isToday: true,
      isOrganizer: false,
      isFavoritedByUser: true,
      likesCount: 12,
      isLiked: false,
      speakers: 'Др. Иванов А.А.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    );

    // Mock favorite clubs
    _favoriteClubs = [
      Club(
        id: 1,
        name: 'КПТ-клуб',
        slug: 'cbt-club',
        description: 'Клуб когнитивно-поведенческой терапии',
        image: null,
        zoomLink: _isPremium ? 'https://zoom.us/j/club1' : null,
        materialsFolderUrl: null,
        autoMaterials: false,
        currentDonations: 15000.0,
        formattedCurrentDonations: '15 000 ₽',
        status: 'active',
        productLevel: 2,
        owner: widget.user,
        isFavoritedByUser: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        speakers: 'Др. Петров В.В.',
      ),
      Club(
        id: 2,
        name: 'Психоаналитический клуб',
        slug: 'psychoanalytic-club',
        description: 'Углубленное изучение психоанализа',
        image: null,
        zoomLink: _isPremium ? 'https://zoom.us/j/club2' : null,
        materialsFolderUrl: null,
        autoMaterials: true,
        currentDonations: 8500.0,
        formattedCurrentDonations: '8 500 ₽',
        status: 'active',
        productLevel: 3,
        owner: widget.user,
        isFavoritedByUser: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        speakers: 'Др. Сидорова Е.И.',
      ),
    ];

    // Mock favorite courses
    _favoriteCourses = [
      Course(
        id: 1,
        title: 'Курс по работе с депрессией',
        slug: 'depression-treatment-course',
        description: 'Комплексный курс по диагностике и лечению депрессивных расстройств',
        shortDescription: 'Диагностика и лечение депрессии',
        image: null,
        maxParticipants: 30,
        publishedAt: DateTime.now().subtract(const Duration(days: 15)),
        formattedPublishedAt: '15 дней назад',
        zoomLink: _isPremium ? 'https://zoom.us/j/course1' : null,
        materialsFolderUrl: null,
        autoMaterials: true,
        productLevel: 2,
        isHidden: false,
        isFavoritedByUser: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        contentCount: 12,
      ),
    ];

    // Mock upcoming meetings
    _upcomingMeetings = [
      _nextMeeting,
      Meeting(
        id: 2,
        name: 'Супервизия по семейной терапии',
        slug: 'family-therapy-supervision',
        description: 'Групповая супервизия для семейных терапевтов',
        image: null,
        date: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        formattedDate: 'Завтра',
        startTime: DateTime.now().add(const Duration(days: 1, hours: 18)).toIso8601String(),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 20)).toIso8601String(),
        formattedStartTime: '18:00',
        formattedEndTime: '20:00',
        duration: '2 часа',
        format: 'online',
        formatLabel: 'Онлайн',
        platform: 'Zoom',
        joinUrl: _isPremium ? 'https://zoom.us/j/987654321' : null,
        location: null,
        maxParticipants: 25,
        status: 'upcoming',
        statusLabel: 'Предстоящая',
        organizer: widget.user,
        participantsCount: 18,
        commentsCount: 3,
        isUpcoming: true,
        isPast: false,
        isToday: false,
        isOrganizer: false,
        isFavoritedByUser: true,
        likesCount: 8,
        isLiked: false,
        speakers: 'Др. Козлова М.С.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Mock recent news
    _recentNews = [
      _latestNews,
      News(
        id: 2,
        title: 'Новые методики в психотерапии',
        slug: 'new-therapy-methods',
        content: 'Содержание второй новости...',
        excerpt: 'Обзор современных подходов в психотерапии...',
        imageUrl: null,
        type: 'article',
        typeLabel: 'Статья',
        priority: 'medium',
        priorityLabel: 'Средний',
        priorityColor: '#F59E0B',
        isFeatured: false,
        isPinned: false,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        formattedPublishedAt: '1 день назад',
        author: widget.user,
        isOrganizationAuthor: false,
        likesCount: 7,
        dislikesCount: 1,
        isLiked: false,
        isDisliked: false,
        viewsCount: 89,
        commentsCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Mock continue watching list
    _continueWatchingList = [
      _continueWatchingVideo,
      Video(
        id: 3,
        title: 'Групповая терапия: основы',
        slug: 'group-therapy-basics',
        description: 'Введение в групповую терапию',
        videoUrl: 'https://example.com/video3.mp4',
        videoId: 'video3',
        thumbnailUrl: null,
        durationMinutes: 30,
        actualDuration: 1800,
        formattedDuration: '30 мин',
        viewCount: 67,
        isFree: false,
        canWatch: _isPremium,
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    // Mock unread notification
    _unreadNotification = _isPremium ? 'Изменение расписания встречи "Разбор клинических случаев"' : null;
  }

  void _initializeFavoritesFromApi(List<dynamic> favorites) {
    _favoriteClubs = [];
    _favoriteCourses = [];

    print('🔄 Начинаем парсинг ${favorites.length} избранных элементов');

    for (final favorite in favorites) {
      final favorable = favorite['favorable'] as Map<String, dynamic>;
      final favorableType = favorite['favorable_type'] as String;

      print('📝 Тип: $favorableType, ID: ${favorable['id']}');

      if (favorableType == 'App\\Models\\Club') {
        try {
          _favoriteClubs.add(Club.fromJson(favorable));
          print('✅ Добавлен клуб: ${favorable['name'] ?? favorable['title']}');
        } catch (e) {
          print('❌ Ошибка парсинга клуба: $e');
        }
      } else if (favorableType == 'App\\Models\\Course') {
        try {
          _favoriteCourses.add(Course.fromJson(favorable));
          print('✅ Добавлен курс: ${favorable['title'] ?? favorable['name']}');
        } catch (e) {
          print('❌ Ошибка парсинга курса: $e');
        }
      }
    }

    print('📊 Итого: ${_favoriteClubs.length} клубов, ${_favoriteCourses.length} курсов');
  }

  void _initializeFallbackNews() {
    _latestNews = News(
      id: 1,
      title: 'Добро пожаловать!',
      slug: 'welcome',
      content: 'Добро пожаловать в приложение АЧПП',
      excerpt: 'Начните знакомство с нашей платформой',
      imageUrl: null,
      type: 'announcement',
      typeLabel: 'Объявление',
      priority: 'normal',
      priorityLabel: 'Обычный',
      priorityColor: '#6B7280',
      isFeatured: true,
      isPinned: false,
      publishedAt: DateTime.now(),
      formattedPublishedAt: 'Только что',
      author: widget.user,
      isOrganizationAuthor: true,
      likesCount: 0,
      dislikesCount: 0,
      isLiked: false,
      isDisliked: false,
      viewsCount: 1,
      commentsCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _initializeFallbackVideo() {
    _latestVideo = Video(
      id: 1,
      title: 'Добро пожаловать',
      slug: 'welcome-video',
      description: 'Начните знакомство с нашей платформой',
      videoUrl: null,
      videoId: 'welcome',
      thumbnailUrl: null,
      durationMinutes: 1,
      actualDuration: 60,
      formattedDuration: '1 мин',
      viewCount: 0,
      isFree: true,
      canWatch: true,
      publishedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _initializeFallbackData() {
    // Инициализируем fallback данные если массивы пустые
    if (_favoriteClubs.isEmpty) {
      _favoriteClubs = [];
    }
    if (_favoriteCourses.isEmpty) {
      _favoriteCourses = [];
    }
    if (_upcomingMeetings.isEmpty) {
      _upcomingMeetings = [];
    }
    if (_continueWatchingList.isEmpty) {
      _continueWatchingList = [_latestVideo];
    }
    if (_videoProgress.isEmpty) {
      _videoProgress = {};
    }

    // Инициализируем _continueWatchingVideo как первое видео из списка
    if (_continueWatchingList.isNotEmpty) {
      _continueWatchingVideo = _continueWatchingList.first;
    } else {
      _continueWatchingVideo = _latestVideo;
    }

    // Инициализируем _nextMeeting как первую встречу или fallback
    if (_upcomingMeetings.isNotEmpty) {
      _nextMeeting = _upcomingMeetings.first;
    } else {
      _nextMeeting = Meeting(
        id: 1,
        name: 'Ближайшие мероприятия скоро появятся',
        slug: 'no-meetings',
        description: 'Следите за обновлениями',
        image: null,
        date: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        formattedDate: 'Через неделю',
        startTime: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        endTime: DateTime.now().add(const Duration(days: 7, hours: 1)).toIso8601String(),
        formattedStartTime: '10:00',
        formattedEndTime: '11:00',
        duration: '1 час',
        format: 'online',
        formatLabel: 'Онлайн',
        platform: 'Zoom',
        joinUrl: null,
        location: null,
        maxParticipants: 100,
        status: 'upcoming',
        statusLabel: 'Предстоящая',
        organizer: widget.user,
        participantsCount: 0,
        commentsCount: 0,
        isUpcoming: true,
        isPast: false,
        isToday: false,
        isOrganizer: false,
        isFavoritedByUser: false,
        likesCount: 0,
        isLiked: false,
        speakers: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    _recentNews = [_latestNews];
  }

  String _formatProgressTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  String _getVideoProgressText(int videoId) {
    final progress = _videoProgress[videoId];
    if (progress != null && progress['progress_seconds'] != null) {
      final progressSeconds = progress['progress_seconds'] as int;
      final completed = progress['completed'] as bool? ?? false;

      if (completed) {
        return 'Просмотрено';
      } else {
        return _formatProgressTime(progressSeconds);
      }
    }
    return 'Не просмотрено';
  }

  List<dynamic> _safeGetList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is List<dynamic>) {
      return value;
    }
    print('⚠️ Ожидался массив для ключа "$key", но получен: ${value.runtimeType}');
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // Unread Notification
          if (_unreadNotification != null) _buildNotificationCard(),
          
          // Favorite Clubs & Courses
          if (_favoriteClubs.isNotEmpty || _favoriteCourses.isNotEmpty)
            _buildFavoritesSection(),
          
          // Upcoming Meetings
          if (_upcomingMeetings.isNotEmpty) _buildUpcomingMeetings(),
          
          // Continue Watching
          if (_isPremium) _buildContinueWatching(),
          
          // Latest News
          _buildLatestNews(),
          
          // Recent News
          _buildRecentNews(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget _buildNotificationCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Новое уведомление',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _unreadNotification!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _unreadNotification = null;
              });
            },
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection() {
    // Объединяем все избранные элементы в один список
    final allFavorites = <Map<String, dynamic>>[];

    // Добавляем клубы
    for (final club in _favoriteClubs) {
      allFavorites.add({
        'type': 'club',
        'item': club,
        'created_at': club.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      });
    }

    // Добавляем курсы
    for (final course in _favoriteCourses) {
      allFavorites.add({
        'type': 'course',
        'item': course,
        'created_at': course.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      });
    }

    // Сортируем по дате добавления (сначала новые)
    allFavorites.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Мои избранные',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (allFavorites.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'У вас пока нет избранных элементов',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: allFavorites.length,
            itemBuilder: (context, index) {
              final favorite = allFavorites[index];
              return _buildFavoriteCard(favorite);
            },
          ),
      ],
    );
  }


  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
    final type = favorite['type'] as String;
    final item = favorite['item'];
    final createdAt = favorite['created_at'] as String;

    String title = '';
    String subtitle = '';
    IconData icon = Icons.favorite;
    Color cardColor = const Color(0xFF2D2D2D);

    String? description;
    String? zoomLink;
    Map<String, dynamic>? nextMeeting;
    Map<String, dynamic>? nextContent;

    if (type == 'club') {
      final club = item as Club;
      title = club.name;
      subtitle = 'Клуб';
      icon = Icons.group;
      description = club.description;
      zoomLink = club.zoomLink;
      // Для клубов используем nextMeeting как Map
      if (club.nextMeeting != null) {
        nextMeeting = {
          'name': 'Встреча клуба', // Используем фиксированное название
          'date': club.nextMeeting!.date,
          'start_time': club.nextMeeting!.startTime,
          'end_time': club.nextMeeting!.endTime,
          'speakers': club.nextMeeting!.speakers,
        };
      }
    } else if (type == 'course') {
      final course = item as Course;
      title = course.title;
      subtitle = 'Курс';
      icon = Icons.school;
      description = course.shortDescription;
      zoomLink = course.zoomLink;
      // Для курсов используем nextContent как Map
      if (course.nextContent != null) {
        nextContent = {
          'title': course.nextContent!.title,
          'date': course.nextContent!.date,
          'start_time': course.nextContent!.startTime,
          'end_time': course.nextContent!.endTime,
          'speakers': course.nextContent!.speakers,
        };
      }
    }

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
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (type == 'club') {
            _openClub(item as Club);
          } else if (type == 'course') {
            _openCourse(item as Course);
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
                      color: const Color(0xFF6B46C1).withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFF6B46C1), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
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
                    color: Colors.grey[300],
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
                    color: const Color(0xFF6B46C1).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF6B46C1).withAlpha(77)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16, color: Color(0xFF6B46C1)),
                          const SizedBox(width: 6),
                          Text(
                            'Следующее событие',
                            style: TextStyle(
                              color: const Color(0xFF6B46C1),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nextTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (nextLine != null && nextLine.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          nextLine,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (speakers != null && speakers.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                speakers,
                                style: TextStyle(
                                  color: Colors.grey[400],
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
                    SizedBox(
                      height: 28,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _openZoomLink(zoomLink!);
                        },
                        icon: const Icon(Icons.videocam, size: 14),
                        label: const Text(
                          'Подключиться к Zoom',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D8CFF), // Синий цвет для Zoom
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          minimumSize: const Size(0, 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(
                      color: Colors.grey[500],
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

  Widget _buildUpcomingMeetings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Ближайшие встречи',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _upcomingMeetings.length,
          itemBuilder: (context, index) {
            final meeting = _upcomingMeetings[index];
            final isSoon = meeting.isToday && 
                DateTime.now().add(const Duration(hours: 2)).isAfter(DateTime.parse(meeting.startTime));
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSoon ? const Color(0xFF10B981) : const Color(0xFF374151),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meeting.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Скоро',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${meeting.formattedDate}, ${meeting.formattedStartTime}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${meeting.participantsCount}/${meeting.maxParticipants} участников',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isPremium ? () => _joinMeeting(meeting) : _showUpgradeDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _isPremium ? 'Подключиться' : 'Выбрать тариф',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _openMeeting(meeting),
                        child: const Text(
                          'Подробнее',
                          style: TextStyle(color: Color(0xFF8B5CF6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContinueWatching() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Продолжить просмотр',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _continueWatchingList.length,
                            itemBuilder: (context, index) {
              final video = _continueWatchingList[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openVideo(video),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.play_circle_filled, color: Color(0xFF8B5CF6), size: 20),
                              const Spacer(),
                              Text(
                                _getVideoProgressText(video.id),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            video.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            video.formattedDuration,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLatestNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Свежая новость',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _latestNews.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _latestNews.excerpt,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _latestNews.formattedPublishedAt!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _openNews(_latestNews),
                    child: const Text(
                      'Читать',
                      style: TextStyle(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Новости',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentNews.length,
          itemBuilder: (context, index) {
            final news = _recentNews[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[400],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news.formattedPublishedAt!,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _openNews(news),
                        child: const Text(
                          'Читать',
                          style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Navigation methods
  void _openVideo(Video video) {
    // TODO: Navigate to video player
    print('Opening video: ${video.title}');
  }

  void _joinMeeting(Meeting meeting) {
    if (meeting.joinUrl != null) {
      // TODO: Open Zoom link
      print('Joining meeting: ${meeting.name}');
      print('Zoom URL: ${meeting.joinUrl}');
    } else {
      _showUpgradeDialog();
    }
  }

  void _openNews(News news) {
    // TODO: Navigate to news detail
    print('Opening news: ${news.title}');
  }

  void _openClub(Club club) {
    context.go('/clubs/${club.slug}');
  }

  void _openCourse(Course course) {
    context.go('/courses/${course.slug}');
  }

  void _openMeeting(Meeting meeting) {
    // TODO: Navigate to meeting detail
    print('Opening meeting: ${meeting.name}');
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Выбрать тариф',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Для доступа к этому контенту необходимо выбрать подходящий тариф.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to subscription screen
              print('Navigate to subscription screen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Выбрать тариф'),
          ),
        ],
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

  void _openZoomLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось открыть ссылку Zoom'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
