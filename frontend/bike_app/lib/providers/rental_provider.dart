import 'package:flutter/material.dart';
import '../screens/rentals/rental_bike.dart';
import '../services/rental_service.dart';

class RentalProvider extends ChangeNotifier {
  List<RentalBike> bikes = [];
  bool isLoading = false;

  Future<void> fetchBikes() async {
    isLoading = true;
    notifyListeners();
    try {
      bikes = await RentalService.fetchBikes();
    } catch (e) {
      debugPrint('⚠️ fetchRentalBikes failed: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Distinct category names in the order they first appear, derived
  /// from whatever bikes actually came back — no separate categories
  /// call needed.
  List<String> get categoryLabels {
    final seen = <String>{};
    final labels = <String>[];
    for (final b in bikes) {
      if (seen.add(b.category.slug)) labels.add(b.category.name);
    }
    return labels;
  }
}
