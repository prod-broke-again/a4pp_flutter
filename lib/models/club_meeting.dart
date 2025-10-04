class ClubMeeting {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final String? speakers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ClubMeeting({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.speakers,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ClubMeeting.fromJson(Map<String, dynamic> json) {
    return ClubMeeting(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      speakers: json['speakers'] as String?,
      createdAt: json['created_at'] != null ? _tryParseDateTime(json['created_at']) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? _tryParseDateTime(json['updated_at']) ?? DateTime.now() : DateTime.now(),
      deletedAt: json['deleted_at'] != null ? _tryParseDateTime(json['deleted_at']) : null,
    );
  }

  static DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) {
        return DateTime.parse(value);
      }
      return null;
    } catch (e) {
      print('❌ Ошибка парсинга даты: $e, значение: $value');
      return null;
    }
  }

  String getDuration() {
    try {
      // Парсим полные ISO строки в DateTime
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);

      final diff = end.difference(start);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;

      if (hours > 0) {
        return '${hours}ч ${minutes > 0 ? '$minutesм' : ''}'.trim();
      } else {
        return '${minutes}м';
      }
    } catch (_) {
      return '0м';
    }
  }
}
