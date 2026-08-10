class Bike {
  final int id;
  final String name;
  final String category;

  /// Full URL to the bike's main product photo, used by
  /// `_BikeVisual` (via `Image.network`) and by `Bike360ViewerScreen`'s
  /// pseudo-3D-spin fallback when no 360 frame set is configured for
  /// this bike.
  final String heroImage;

  Bike({
    required this.id,
    required this.name,
    required this.category,
    required this.heroImage,
  });

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json["id"],
      name: json["name"],
      category: json["category"]["slug"] as String? ?? '',
      heroImage:
          json["hero_image"] as String? ?? json["image"] as String? ?? '',
    );
  }
}
