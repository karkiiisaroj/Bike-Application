import '../screens/rentals/rental_bike.dart';
import '../models/booking_record_model.dart';
import 'api_client.dart';

class RentalService {
  static Future<List<RentalBike>> fetchBikes() async {
    final data = await ApiClient.get('/rentals/bikes/', auth: false);
    final list = data['data'] as List? ?? [];
    return list
        .map((e) => RentalBike.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Map<String, String>>> fetchBookedRanges(int bikeId) async {
    final data = await ApiClient.get(
      '/rentals/bikes/$bikeId/availability/',
      auth: false,
    );
    final list = data['data'] as List? ?? [];
    return list
        .map(
          (e) => {
            'start_date': e['start_date'] as String,
            'end_date': e['end_date'] as String,
          },
        )
        .toList();
  }

  static Future<BookingRecord> createBooking({
    required int bikeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final data = await ApiClient.post('/rentals/bookings/', {
      'bike': bikeId,
      'start_date': _fmt(startDate),
      'end_date': _fmt(endDate),
    }, auth: true);
    return BookingRecord.fromJson(data);
  }

  static Future<List<BookingRecord>> fetchMyBookings() async {
    final data = await ApiClient.get('/rentals/bookings/mine/', auth: true);
    final list = data['data'] as List? ?? [];
    return list
        .map((e) => BookingRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<BookingRecord> cancelBooking(int bookingId) async {
    final data = await ApiClient.patch(
      '/rentals/bookings/$bookingId/cancel/',
      {},
      auth: true,
    );
    return BookingRecord.fromJson(data);
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
