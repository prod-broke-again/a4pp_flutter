import 'package:dio/dio.dart';
import 'dart:io';
import 'package:mobile/services/api_client.dart';

class MeetingRepository {
  final ApiClient _apiClient;

  MeetingRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Получить ближайшие встречи для домашнего экрана
  Future<Map<String, dynamic>> getUpcomingMeetings({int limit = 3}) async {
    try {
      final response = await _apiClient.dio.get('/meetings', queryParameters: {
        'per_page': limit,
        'sort': 'date',
        'order': 'asc',
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить ближайшие встречи');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Список встреч: GET /meetings
  Future<Map<String, dynamic>> list({
    int page = 1,
    int perPage = 15,
    String? search,
    String? status,
    String? format,
    String? dateFrom,
    String? dateTo,
    String? sort,
    String? order,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (format != null && format.isNotEmpty) query['format'] = format;
      if (dateFrom != null && dateFrom.isNotEmpty) query['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) query['date_to'] = dateTo;
      if (sort != null && sort.isNotEmpty) query['sort'] = sort;
      if (order != null && order.isNotEmpty) query['order'] = order;

      final response = await _apiClient.dio.get('/meetings', queryParameters: query);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить встречи');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Детали встречи: GET /meetings/{slug}
  Future<Map<String, dynamic>> get(String slug) async {
    try {
      final response = await _apiClient.dio.get('/meetings/$slug');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось загрузить встречу');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Регистрация: POST /meetings/{slug}/register
  Future<Map<String, dynamic>> register(String slug) async {
    try {
      final response = await _apiClient.dio.post('/meetings/$slug/register');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось зарегистрироваться');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Отмена регистрации: DELETE /meetings/{slug}/unregister
  Future<Map<String, dynamic>> unregister(String slug) async {
    try {
      final response = await _apiClient.dio.delete('/meetings/$slug/unregister');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось отменить регистрацию');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }

  /// Донат: POST /meetings/{slug}/donate
  Future<Map<String, dynamic>> donate(String slug, {required num amount}) async {
    try {
      final response = await _apiClient.dio.post(
        '/meetings/$slug/donate',
        data: {'amount': amount},
      );
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

  /// Создание встречи: POST /meetings
  Future<Map<String, dynamic>> create({
    required String name,
    String? description,
    String? image,
    File? imageFile,
    required String date, // YYYY-MM-DD
    required String startTime, // HH:MM or HH:MM:SS
    required String endTime, // HH:MM or HH:MM:SS
    String format = 'online', // online|offline|hybrid
    String? platform,
    String? joinUrl,
    String? location,
    int? maxParticipants,
    String status = 'published', // draft|published|completed|cancelled
    String? notes,
    int? categoryId,
  }) async {
    try {
      final useMultipart = imageFile != null;

      dynamic body;
      Options? options;
      if (useMultipart) {
        body = FormData.fromMap({
          'name': name,
          if (description != null) 'description': description,
          'date': date,
          'start_time': startTime,
          'end_time': endTime,
          'format': format,
          if (platform != null) 'platform': platform,
          if (joinUrl != null) 'join_url': joinUrl,
          if (location != null) 'location': location,
          if (maxParticipants != null) 'max_participants': maxParticipants,
          'status': status,
          if (notes != null) 'notes': notes,
          if (categoryId != null) 'category_id': categoryId,
          'image': await MultipartFile.fromFile(imageFile!.path, filename: imageFile.path.split('/').last),
        });
        options = Options(contentType: 'multipart/form-data');
      } else {
        body = <String, dynamic>{
          'name': name,
          if (description != null) 'description': description,
          if (image != null) 'image': image,
          'date': date,
          'start_time': startTime,
          'end_time': endTime,
          'format': format,
          if (platform != null) 'platform': platform,
          if (joinUrl != null) 'join_url': joinUrl,
          if (location != null) 'location': location,
          if (maxParticipants != null) 'max_participants': maxParticipants,
          'status': status,
          if (notes != null) 'notes': notes,
          if (categoryId != null) 'category_id': categoryId,
        };
      }

      final response = await _apiClient.dio.post('/meetings', data: body, options: options);
      if (response.statusCode == 201 || (response.statusCode == 200 && response.data['success'] == true)) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Не удалось создать встречу');
    } on DioException catch (e) {
      final normalized = e.error;
      if (normalized is Object) return Future.error(normalized.toString());
      return Future.error('Ошибка сети. Повторите попытку.');
    }
  }
}


