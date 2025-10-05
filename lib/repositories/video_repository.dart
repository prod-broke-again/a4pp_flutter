import 'package:dio/dio.dart';
import 'package:achpp/services/api_client.dart';

class VideoRepository {
  final ApiClient _apiClient;

  VideoRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Получить популярные видео для продолжения просмотра (пока нет истории просмотров)
  Future<Map<String, dynamic>> getContinueWatchingVideos({int limit = 3}) async {
    try {
      print('📡 VIDEO API: Запрос GET /videos для продолжения просмотра (популярные видео)');
      final response = await _apiClient.dio.get('/videos', queryParameters: {
        'per_page': limit,
        'sort_by': 'view_count',
        'sort_direction': 'desc',
        'is_free': false, // Показываем платные видео для премиум пользователей
      });
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось загрузить видео для продолжения');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить последнее видео для домашнего экрана
  Future<Map<String, dynamic>> getLatestVideo() async {
    try {
      print('📡 VIDEO API: Запрос GET /videos для последнего видео');
      final response = await _apiClient.dio.get('/videos', queryParameters: {
        'per_page': 1,
        'sort_by': 'published_at',
        'sort_direction': 'desc',
      });
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось загрузить последнее видео');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить все категории видео (корневые папки)
  Future<Map<String, dynamic>> getVideoCategories() async {
    try {
      print('📡 VIDEO API: Запрос GET /v2/videos/categories');
      final response = await _apiClient.dio.get('/v2/videos/categories');
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось загрузить категории видео');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить подкатегории для категории
  Future<Map<String, dynamic>> getVideoCategorySubcategories(int categoryId) async {
    try {
      print('📡 VIDEO API: Запрос GET /v2/videos/categories/$categoryId/subcategories');
      final response = await _apiClient.dio.get('/v2/videos/categories/$categoryId/subcategories');
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось загрузить подкатегории');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить видео категории (корневой или подкатегории)
  Future<Map<String, dynamic>> getVideoCategory(String categorySlug, {String? search, int page = 1, int perPage = 15}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      print('📡 VIDEO API: Запрос GET /v2/videos/category/$categorySlug с параметрами: $queryParams');
      final response = await _apiClient.dio.get(
        '/v2/videos/category/$categorySlug',
        queryParameters: queryParams,
      );
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось загрузить видео категории');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить список видео с фильтрацией
  Future<Map<String, dynamic>> getVideos({String? search, int? videoFolderId, int page = 1, int perPage = 15}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (videoFolderId != null) {
        queryParams['video_folder_id'] = videoFolderId;
      }

      print('📡 VIDEO API: Запрос GET /v2/videos с параметрами: $queryParams');
      final response = await _apiClient.dio.get(
        '/v2/videos',
        queryParameters: queryParams,
      );
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось загрузить видео');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить конкретное видео
  Future<Map<String, dynamic>> getVideo(String slug) async {
    try {
      print('📡 VIDEO API: Запрос GET /v2/videos/$slug');
      final response = await _apiClient.dio.get('/v2/videos/$slug');
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось загрузить видео');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Получить видео из папки для навигации
  Future<Map<String, dynamic>> getVideoNavigation(String slug) async {
    try {
      print('📡 VIDEO API: Запрос GET /v2/videos/$slug/folder-videos');
      final response = await _apiClient.dio.get('/v2/videos/$slug/folder-videos');
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось загрузить навигацию');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Поставить/убрать лайк видео
  Future<Map<String, dynamic>> toggleVideoLike(String slug) async {
    try {
      print('📡 VIDEO API: Запрос POST /v2/videos/$slug/like');
      final response = await _apiClient.dio.post('/v2/videos/$slug/like');
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось выполнить действие');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Поставить/убрать дизлайк видео
  Future<Map<String, dynamic>> toggleVideoDislike(String slug) async {
    try {
      print('📡 VIDEO API: Запрос POST /v2/videos/$slug/dislike');
      final response = await _apiClient.dio.post('/v2/videos/$slug/dislike');
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось выполнить действие');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Отслеживать просмотр видео
  Future<Map<String, dynamic>> trackVideoView(String slug) async {
    try {
      print('📡 VIDEO API: Запрос POST /v2/videos/$slug/views');
      final response = await _apiClient.dio.post('/v2/videos/$slug/views');
      print('📡 VIDEO API: Ответ - статус ${response.statusCode}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data);
        }
        // API может вернуть data = null, тогда просто вернём пустую map
        return <String, dynamic>{};
      }
      print('❌ VIDEO API: Неуспешный ответ - статус ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось отслеживать просмотр');
    } on DioException catch (e) {
      print('❌ VIDEO API: DioException - тип ${e.type}, сообщение: ${e.message}');
      print('❌ VIDEO API: Код ответа: ${e.response?.statusCode}');
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }
}
