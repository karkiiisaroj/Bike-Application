class BookingRecord {
  final int id;
  final int bikeId;
  final String bikeName;
  final String bikeTagline;
  final String bikeCategory;
  final int pricePerDay;
  final String heroImage;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;
  final String status;
  final DateTime createdAt;

  BookingRecord({
    required this.id,
    required this.bikeId,
    required this.bikeName,
    required this.bikeTagline,
    required this.bikeCategory,
    required this.pricePerDay,
    required this.heroImage,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  int get days => endDate.difference(startDate).inDays + 1;

  factory BookingRecord.fromJson(Map<String, dynamic> json) {
    final bikeDetail = json['bike_detail'] as Map<String, dynamic>?;
    final category = bikeDetail?['category'] as Map<String, dynamic>?;
    return BookingRecord(
      id: json['id'],
      bikeId: json['bike'],
      bikeName: bikeDetail?['name'] as String? ?? 'Unknown bike',
      bikeTagline: bikeDetail?['tagline'] as String? ?? '',
      bikeCategory: category?['name'] as String? ?? '',
      pricePerDay: bikeDetail?['price_per_day'] as int? ?? 0,
      heroImage: bikeDetail?['hero_image'] as String? ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: json['total_price'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
