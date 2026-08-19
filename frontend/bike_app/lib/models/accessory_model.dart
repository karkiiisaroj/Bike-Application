/// Mirrors AccessoryListSerializer / AccessoryDetailSerializer on the
/// Django side. `description`, `stock`, and `compatibleBikes` are only
/// populated by the detail endpoint — the list endpoint (grid/browse)
/// leaves them at their defaults to keep that response light.
class Accessory {
  final int id;
  final String slug;
  final String name;
  final int price;
  final String category;
  final String? imageUrl;
  final bool inStock;
  final String description;
  final int stock;
  final List<String> compatibleBikes;

  const Accessory({
    required this.id,
    required this.slug,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
    this.inStock = true,
    this.description = '',
    this.stock = 0,
    this.compatibleBikes = const [],
  });

  factory Accessory.fromJson(Map<String, dynamic> json) {
    return Accessory(
      id: json['id'] as int,
      slug: json['slug'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      inStock: json['in_stock'] as bool? ?? true,
      description: json['description'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      compatibleBikes:
          (json['compatible_bikes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

/// Segment id → display label — unchanged from the old local catalog.
/// These ids must match `AccessoryCategory` choices on the Django side.
const Map<String, String> accessoryCategoryLabels = {
  'heritage': 'Heritage',
  'adventure': 'Adventure',
  'roadster': 'Roadster',
  'cruiser': 'Cruiser',
  'scrambler': 'Scrambler',
  'pure-sport': 'Pure-Sport',
};

String formatRupees(int price) {
  final s = price.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
