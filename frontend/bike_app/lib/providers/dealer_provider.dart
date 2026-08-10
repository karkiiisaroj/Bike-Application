import 'package:bike_app/models/dealer_model.dart';
import 'package:bike_app/services/api_services.dart';
import 'package:flutter/material.dart';

class DealerProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  List<Dealer> dealers = [];
  bool isLoading = false;

  Future<void> fetchDealers() async {
    isLoading = true;
    notifyListeners();
    try {
      dealers = await api.getDealers();
    } catch (e) {
      debugPrint('⚠️ fetchDealers failed: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
