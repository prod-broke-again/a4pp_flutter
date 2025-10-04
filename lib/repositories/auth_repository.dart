import 'package:mobile/models/user.dart';
import 'package:mobile/models/profile_response.dart';
import 'package:mobile/services/api_client.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = User.fromJson(response.data['data']['user']);
        final token = response.data['data']['token'] as String;
        await _apiClient.saveToken(token);
        return {'user': user, 'token': token};
      }

      throw Exception(response.data['message'] ?? 'Не удалось выполнить вход');
    } on DioException catch (e) {
      final normalized = e.error; // _NormalizedApiError
      if (normalized is Object) {
        return Future.error(normalized.toString());
      }
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = User.fromJson(response.data['data']['user']);
        final token = response.data['data']['token'] as String;
        await _apiClient.saveToken(token);
        return {'user': user, 'token': token};
      }

      throw Exception(response.data['message'] ?? 'Не удалось зарегистрироваться');
    } on DioException catch (e) {
      final normalized = e.error; // _NormalizedApiError
      if (normalized is Object) {
        return Future.error(normalized.toString());
      }
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } finally {
      await _apiClient.clearToken();
    }
  }

  Future<bool> hasToken() => _apiClient.hasToken();

  Future<ProfileData> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/profile');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProfileData.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить профиль');
    } on DioException catch (e) {
      final normalized = e.error; // _NormalizedApiError
      if (normalized is Object) {
        return Future.error(normalized.toString());
      }
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> getTransactions({int page = 1, int perPage = 15}) async {
    try {
      final response = await _apiClient.dio.get('/profile/transactions', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить транзакции');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Uri> topupBalance({required double amount, String? successUrl, String? failUrl}) async {
    try {
      final response = await _apiClient.dio.post('/balance/topup', data: {
        'amount': amount,
        if (successUrl != null) 'success_url': successUrl,
        if (failUrl != null) 'fail_url': failUrl,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        final url = response.data['data']['payment_url']?.toString();
        if (url != null && url.isNotEmpty) {
          return Uri.parse(url);
        }
      }
      throw Exception(response.data['message'] ?? 'Не удалось инициировать оплату');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> getFavorites() async {
    try {
      final response = await _apiClient.dio.get('/profile/favorites');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить избранное');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> getClubs({int page = 1, int perPage = 15, String? search, String? status, String? sort, String? order}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (sort != null) queryParams['sort'] = sort;
      if (order != null) queryParams['order'] = order;

      final response = await _apiClient.dio.get('/clubs', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить клубы');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> getClub(String slug) async {
    try {
      final response = await _apiClient.dio.get('/clubs/$slug');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить клуб');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> donateToClub(String slug, double amount) async {
    try {
      final response = await _apiClient.dio.post('/clubs/$slug/donate', data: {
        'amount': amount,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось отправить донат');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> donateToCourse(String slug, double amount) async {
    try {
      final response = await _apiClient.dio.post('/courses/$slug/donate', data: {
        'amount': amount,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось отправить донат');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> getCourses({int page = 1, int perPage = 15, String? search, int? categoryId, String? status, String? sort, String? order}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (status != null) queryParams['status'] = status;
      if (sort != null) queryParams['sort'] = sort;
      if (order != null) queryParams['order'] = order;

      print('🌐 Отправляем запрос к API: GET /courses');
      print('📋 Параметры запроса: $queryParams');
      
      final response = await _apiClient.dio.get('/courses', queryParameters: queryParams);
      
      print('📡 Статус ответа: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final result = Map<String, dynamic>.from(response.data['data']);
        print('✅ Успешно получены данные курсов');
        print('📊 Структура данных: ${result.keys.toList()}');
        if (result.containsKey('courses')) {
          print('📚 Количество курсов: ${(result['courses'] as List).length}');
        }
        return result;
      }
      
      print('❌ API вернул ошибку. Статус: ${response.statusCode}');
      throw Exception(response.data['message'] ?? 'Не удалось загрузить курсы');
    } on DioException catch (e) {
      print('❌ DioException при загрузке курсов: ${e.message}');
      print('🔍 Тип ошибки: ${e.type}');
      print('📊 Код ответа: ${e.response?.statusCode}');
      
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> getCourse(String slug) async {
    try {
      final response = await _apiClient.dio.get('/courses/$slug');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить курс');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> toggleFavorite({required int favorableId, required String favorableType}) async {
    try {
      final response = await _apiClient.dio.post('/favorites/toggle', data: {
        'favorable_id': favorableId,
        'favorable_type': favorableType,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось изменить статус избранного');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> getCurrentSubscription() async {
    try {
      final response = await _apiClient.dio.get('/subscriptions/current');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить текущую подписку');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> getNotifications({int page = 1, int perPage = 10}) async {
    try {
      final response = await _apiClient.dio.get('/notifications', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        // Если data - объект с полями пагинации, извлекаем notifications
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final notifications = data['data'];
          if (notifications is List) {
            return {
              'notifications': notifications,
              'pagination': {
                'current_page': data['current_page'] ?? 1,
                'last_page': data['last_page'] ?? 1,
                'per_page': data['per_page'] ?? perPage,
                'total': data['total'] ?? 0,
              }
            };
          }
        }

        // Если data уже массив уведомлений
        if (data is List) {
          return {
            'notifications': data,
            'pagination': {
              'current_page': 1,
              'last_page': 1,
              'per_page': perPage,
              'total': data.length,
            }
          };
        }

        // Fallback - пустой массив
        return {
          'notifications': [],
          'pagination': {
            'current_page': 1,
            'last_page': 1,
            'per_page': perPage,
            'total': 0,
          }
        };
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить уведомления');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  Future<Map<String, dynamic>> getWatchHistory({int limit = 10}) async {
    try {
      final response = await _apiClient.dio.get('/profile/watch-history', queryParameters: {
        'limit': limit,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить историю просмотров');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

}
