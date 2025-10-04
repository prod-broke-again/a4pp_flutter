class NavigationVideo {
  final int id;
  final String title;
  final String slug;
  final String? thumbnailUrl;
  final bool canWatch;
  final int? sortOrder;
  final DateTime? publishedAt;
  final int durationMinutes;
  final String formattedDuration;

  NavigationVideo({
    required this.id,
    required this.title,
    required this.slug,
    this.thumbnailUrl,
    required this.canWatch,
    this.sortOrder,
    this.publishedAt,
    required this.durationMinutes,
    required this.formattedDuration,
  });

  factory NavigationVideo.fromJson(Map<String, dynamic> json) {
    return NavigationVideo(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      canWatch: json['can_watch'] as bool? ?? false,
      sortOrder: json['sort_order'] as int?,
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at'] as String) : null,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      formattedDuration: json['formatted_duration'] as String? ?? '0 мин',
    );
  }
}
