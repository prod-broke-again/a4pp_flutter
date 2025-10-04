import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiClient {
  ApiClient._internal();

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio = _createDio();

  static const String _baseUrl = 'https://appp-psy.ru/api';
  static const String _authTokenKey = 'auth_token';

  Dio _createDio() {
    final options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    final dio = Dio(options);

    // Логирование запросов/ответов (в консоль) - МИНИМАЛЬНОЕ (только заголовки для проверки Accept)
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
      logPrint: (obj) {
        final line = obj.toString().replaceAll(RegExp('Bearer [A-Za-z0-9._\-]+' ), 'Bearer ***');
        // ignore: avoid_print
        print(line);
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_authTokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        String friendlyMessage = 'Произошла ошибка. Повторите попытку позже.';
        Map<String, dynamic>? validationErrors;
        int? statusCode;

        if (error is DioException) {
          statusCode = error.response?.statusCode;
          final data = error.response?.data;
          if (data is Map<String, dynamic>) {
            if (data['message'] is String && (data['message'] as String).isNotEmpty) {
              friendlyMessage = data['message'] as String;
            }
            if (data['errors'] is Map<String, dynamic>) {
              validationErrors = Map<String, dynamic>.from(data['errors'] as Map);
            }
          } else if (data is String && data.trim().isNotEmpty) {
            friendlyMessage = data;
          }

          if (statusCode == 401) {
            friendlyMessage = friendlyMessage.isNotEmpty
                ? friendlyMessage
                : 'Не авторизован. Проверьте логин/пароль.';
          }

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: _NormalizedApiError(
                message: friendlyMessage,
                statusCode: statusCode,
                errors: validationErrors,
              ),
            ),
          );
        }

        return handler.next(error);
      },
    ));

    return dio;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }

  // Базовые HTTP методы
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.delete(path, data: data, queryParameters: queryParameters);
  }

  // Методы для работы с файлами
  Future<Response> postFile(String path, File file, {String fieldName = 'file'}) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    return await dio.post(
      path,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

  Future<Response> putFile(String path, File file, {String fieldName = 'file'}) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    return await dio.put(
      path,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }
}

class _NormalizedApiError {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const _NormalizedApiError({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}


