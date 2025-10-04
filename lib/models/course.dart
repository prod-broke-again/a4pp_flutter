class CourseContent {
  final int id;
  final String title;
  final String? description;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? speakers;
  final String? section;
  final String? link;
  final bool isActive;
  final String? formattedDate;
  final String? formattedStartTime;
  final String? formattedEndTime;

  CourseContent({
    required this.id,
    required this.title,
    this.description,
    this.date,
    this.startTime,
    this.endTime,
    this.speakers,
    this.section,
    this.link,
    required this.isActive,
    this.formattedDate,
    this.formattedStartTime,
    this.formattedEndTime,
  });

  static DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return DateTime.tryParse(s);
  }

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      date: _tryParseDate(json['date']),
      startTime: _tryParseDate(json['start_time']),
      endTime: _tryParseDate(json['end_time']),
      speakers: json['speakers'] as String?,
      section: json['section'] as String?,
      link: json['link'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      formattedDate: json['formatted_date'] as String?,
      formattedStartTime: json['formatted_start_time'] as String?,
      formattedEndTime: json['formatted_end_time'] as String?,
    );
  }
}

class Course {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String shortDescription;
  final String? image;
  final int? maxParticipants;
  final DateTime? publishedAt;
  final String formattedPublishedAt;
  final String? zoomLink;
  final String? materialsFolderUrl;
  final bool autoMaterials;
  final int productLevel;
  final bool isHidden;
  final bool isFavoritedByUser;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? contentCount;
  final CourseContent? nextContent;
  final List<CourseContent> contents;

  Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.shortDescription,
    this.image,
    this.maxParticipants,
    this.publishedAt,
    required this.formattedPublishedAt,
    this.zoomLink,
    this.materialsFolderUrl,
    required this.autoMaterials,
    required this.productLevel,
    required this.isHidden,
    required this.isFavoritedByUser,
    required this.createdAt,
    required this.updatedAt,
    this.contentCount,
    this.nextContent,
    this.contents = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Парсинг курса с ID: ${json['id']}');

      // Ищем image_url, иначе image (совместимость)
      final imageUrl = (json['image_url'] ?? json['image']) as String?;

      // Используем title, если есть, иначе name, иначе пустую строку
      final title = json['title'] as String? ?? json['name'] as String? ?? '';

      final course = Course(
        id: json['id'] as int,
        title: title,
        slug: json['slug'] as String? ?? '',
        description: json['description'] as String? ?? '',
        shortDescription: json['short_description'] as String? ?? json['description'] as String? ?? '',
        image: imageUrl,
        maxParticipants: json['max_participants'] as int?,
        publishedAt: json['published_at'] != null ? _tryParseDateTime(json['published_at']) : null,
        formattedPublishedAt: json['formatted_published_at'] as String? ?? '',
        zoomLink: json['zoom_link'] as String?,
        materialsFolderUrl: json['materials_folder_url'] as String?,
        autoMaterials: json['auto_materials'] as bool? ?? false,
        productLevel: json['product_level'] as int? ?? 1,
        isHidden: json['is_hidden'] as bool? ?? false,
        isFavoritedByUser: json['is_favorited_by_user'] as bool? ?? false,
        createdAt: _tryParseDateTime(json['created_at']) ?? DateTime.now(),
        updatedAt: _tryParseDateTime(json['updated_at']) ?? DateTime.now(),
        contentCount: json['content_count'] as int?,
        nextContent: json['next_content'] != null ? CourseContent.fromJson(json['next_content']) : null,
        contents: (json['contents'] as List<dynamic>?)
                ?.map((e) => CourseContent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

      print('✅ Курс успешно распарсен: ${course.title}');
      return course;
    } catch (e, stackTrace) {
      print('❌ Ошибка парсинга курса: $e');
      print('📄 Данные курса: $json');
      print('🔍 Stack trace: $stackTrace');
      rethrow;
    }
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
}
