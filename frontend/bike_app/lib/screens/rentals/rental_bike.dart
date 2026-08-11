class RentalCategory {
  final String slug;
  final String name;

  const RentalCategory({required this.slug, required this.name});

  factory RentalCategory.fromJson(Map<String, dynamic> json) =>
      RentalCategory(slug: json['slug'], name: json['name']);
}

class RentalBike {
  final int id;
  final String name;
  final String tagline;
  final RentalCategory category;
  final int pricePerDay;
  final String heroImage;

  RentalBike({
    required this.id,
    required this.name,
    required this.tagline,
    required this.category,
    required this.pricePerDay,
    required this.heroImage,
  });

  factory RentalBike.fromJson(Map<String, dynamic> json) {
    return RentalBike(
      id: json['id'],
      name: json['name'],
      tagline: json['tagline'] as String? ?? '',
      category: RentalCategory.fromJson(json['category']),
      pricePerDay: json['price_per_day'],
      heroImage: json['hero_image'] as String? ?? '',
    );
  }
}
