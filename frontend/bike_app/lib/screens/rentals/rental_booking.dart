import 'package:bike_app/screens/rentals/rental_bike.dart';

/// Everything the flow has collected so far. Each screen fills in one
/// more field and passes a new copy on to the next screen — nobody
/// needs a global store for a 4-step flow this small.
class RentalBooking {
  final RentalBike bike;
  final int days; // null-ish state handled by RentalPeriodScreen itself
  final DateTime? startDate;

  const RentalBooking({required this.bike, this.days = 1, this.startDate});

  DateTime? get endDate =>
      startDate == null ? null : startDate!.add(Duration(days: days - 1));

  int get totalPrice => bike.pricePerDay * days;

  RentalBooking copyWith({RentalBike? bike, int? days, DateTime? startDate}) {
    return RentalBooking(
      bike: bike ?? this.bike,
      days: days ?? this.days,
      startDate: startDate ?? this.startDate,
    );
  }
}
