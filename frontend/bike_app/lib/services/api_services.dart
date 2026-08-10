import 'dart:convert';

import 'package:bike_app/config/api_config.dart';
import 'package:bike_app/models/bike_model.dart';
import 'package:bike_app/models/dealer_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<Bike>> getBikes() async {
    final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/bikes/"));
    print("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Bike.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load bikes");
    }
  }

  Future<List<Dealer>> getDealers() async {
    final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/dealers/"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Dealer.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load dealers");
    }
  }
}
