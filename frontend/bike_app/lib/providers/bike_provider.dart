import 'package:bike_app/models/bike_model.dart';
import 'package:bike_app/services/api_services.dart';
import 'package:flutter/material.dart';

class BikeProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  List<Bike> bikes = [];
  bool isLoading = false;

  Future<void> fetchBikes() async {
    isLoading = true;
    notifyListeners();
    try {
      bikes = await api.getBikes();
    } catch (e) {
      debugPrint('⚠️ fetchBikes failed: $e');
      // bikes stays whatever it was — empty list if this is the first fetch
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
