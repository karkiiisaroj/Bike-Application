import 'dart:convert';

import 'package:bike_app/config/api_config.dart';
import 'package:bike_app/models/bike_color_variant_model.dart';
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

  // Banners and bike 360-frame sets are static now (see
  // lib/data/static_banners.dart and lib/data/static_bike_frames.dart) —
  // no getBanners()/getBikeFrames() needed here anymore.
  Future<List<BikeColorVariant>> getBikeColorVariants(int bikeId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/bikes/$bikeId/color-variants/"),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => BikeColorVariant.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load color variants");
    }
  }
}
