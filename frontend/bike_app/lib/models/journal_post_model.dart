class JournalPost {
  final String slug;
  final String title;
  final String category;
  final String excerpt;
  final String coverImage;
  final String authorName;
  final int readTimeMinutes;
  final DateTime publishedAt;
  final String? content; // null on list items, populated on detail fetch

  JournalPost({
    required this.slug,
    required this.title,
    required this.category,
    required this.excerpt,
    required this.coverImage,
    required this.authorName,
    required this.readTimeMinutes,
    required this.publishedAt,
    this.content,
  });

  /// Human label for the category slug — 'ride_report' → 'Ride Report'.
  String get categoryLabel {
    switch (category) {
      case 'ride_report':
        return 'Ride Report';
      case 'heritage':
        return 'Heritage';
      case 'gear_guide':
        return 'Gear Guide';
      default:
        return category;
    }
  }

  factory JournalPost.fromJson(Map<String, dynamic> json) {
    return JournalPost(
      slug: json['slug'],
      title: json['title'],
      category: json['category'],
      excerpt: json['excerpt'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Royal Enfield',
      readTimeMinutes: json['read_time_minutes'] as int? ?? 4,
      publishedAt: DateTime.parse(json['published_at']),
      content: json['content'] as String?,
    );
  }
}
