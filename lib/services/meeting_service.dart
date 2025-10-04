import 'dart:io';
import 'package:mobile/models/meeting.dart';
import 'package:mobile/repositories/meeting_repository.dart';

class MeetingService {
  final MeetingRepository _repository;

  MeetingService({MeetingRepository? repository})
      : _repository = repository ?? MeetingRepository();

  /// Получить список встреч с пагинацией и фильтрами
  Future<({
    List<Meeting> meetings,
    Map<String, dynamic> pagination,
  })> getMeetings({
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
    final data = await _repository.list(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
      format: format,
      dateFrom: dateFrom,
      dateTo: dateTo,
      sort: sort,
      order: order,
    );

    final meetings = (data['meetings'] as List<dynamic>)
        .map((json) => Meeting.fromJson(json))
        .toList();
    final pagination = Map<String, dynamic>.from(data['pagination'] as Map);
    return (meetings: meetings, pagination: pagination);
  }

  /// Получить встречу по слагу
  Future<Meeting> getMeeting(String slug) async {
    final data = await _repository.get(slug);
    return Meeting.fromJson(data['meeting']);
  }

  /// Зарегистрироваться на встречу
  Future<bool> register(String slug) async {
    final data = await _repository.register(slug);
    return data['is_registered'] as bool? ?? true;
  }

  /// Отменить регистрацию
  Future<bool> unregister(String slug) async {
    final data = await _repository.unregister(slug);
    return data['is_registered'] as bool? ?? false;
  }

  /// Отправить донат
  Future<({
    num newBalance,
    String formattedBalance,
    int transactionId,
  })> donate(String slug, {required num amount}) async {
    final data = await _repository.donate(slug, amount: amount);
    return (
      newBalance: data['new_balance'] as num,
      formattedBalance: data['formatted_balance'] as String,
      transactionId: data['transaction_id'] as int,
    );
  }

  /// Создать встречу
  Future<Meeting> createMeeting({
    required String name,
    String? description,
    String? image,
    String? imageFilePath,
    required String date, // YYYY-MM-DD
    required String startTime, // HH:MM or HH:MM:SS
    required String endTime, // HH:MM or HH:MM:SS
    String format = 'online',
    String? platform,
    String? joinUrl,
    String? location,
    int? maxParticipants,
    String status = 'published',
    String? notes,
    int? categoryId,
  }) async {
    final data = await _repository.create(
      name: name,
      description: description,
      image: image,
      imageFile: imageFilePath != null ? File(imageFilePath) : null,
      date: date,
      startTime: startTime,
      endTime: endTime,
      format: format,
      platform: platform,
      joinUrl: joinUrl,
      location: location,
      maxParticipants: maxParticipants,
      status: status,
      notes: notes,
      categoryId: categoryId,
    );
    return Meeting.fromJson(data['meeting'] ?? data);
  }
}


