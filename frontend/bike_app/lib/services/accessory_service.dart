import 'dart:convert';

import 'package:bike_app/models/accessory_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AccessoryApi {
  /// Development API URLs:
  ///
  /// Flutter Web       -> 127.0.0.1
  /// Android Emulator  -> 10.0.2.2
  /// Physical Device   -> your computer's LAN IP
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  static Future<List<Accessory>> fetchAccessories({
    String? category,
    String? bikeName,
  }) async {
    final params = <String, String>{};

    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }

    if (bikeName != null && bikeName.isNotEmpty) {
      params['bike'] = bikeName;
    }

    final uri = Uri.parse(
      '$baseUrl/accessories/',
    ).replace(queryParameters: params.isEmpty ? null : params);

    debugPrint('========================================');
    debugPrint('ACCESSORY API REQUEST');
    debugPrint('URL: $uri');
    debugPrint('========================================');

    try {
      final res = await http.get(uri);

      debugPrint('STATUS CODE: ${res.statusCode}');
      debugPrint('RESPONSE: ${res.body}');

      if (res.statusCode != 200) {
        throw Exception(
          'Failed to load accessories '
          '(${res.statusCode}): ${res.body}',
        );
      }

      final decoded = jsonDecode(res.body);

      if (decoded is! List) {
        throw Exception('Invalid response format from accessories API.');
      }

      debugPrint('ACCESSORIES FOUND: ${decoded.length}');

      final accessories = decoded
          .map((e) => Accessory.fromJson(e as Map<String, dynamic>))
          .toList();

      debugPrint('ACCESSORIES PARSED: ${accessories.length}');

      return accessories;
    } catch (e) {
      debugPrint('========================================');
      debugPrint('ACCESSORY API ERROR');
      debugPrint('$e');
      debugPrint('========================================');

      rethrow;
    }
  }

  static Future<Accessory> fetchAccessoryDetail(String slug) async {
    final uri = Uri.parse('$baseUrl/accessories/$slug/');

    debugPrint('ACCESSORY DETAIL URL: $uri');

    final res = await http.get(uri);

    debugPrint('ACCESSORY DETAIL STATUS: ${res.statusCode}');

    debugPrint('ACCESSORY DETAIL RESPONSE: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load accessory '
        '(${res.statusCode}): ${res.body}',
      );
    }

    return Accessory.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> placeOrder({
    required String customerName,
    required String phone,
    String email = '',
    required String address,
    required String city,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final uri = Uri.parse('$baseUrl/accessories/orders/');

    debugPrint('ORDER URL: $uri');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customer_name': customerName,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'payment_method': paymentMethod,
        'items': items,
      }),
    );

    debugPrint('ORDER STATUS: ${res.statusCode}');
    debugPrint('ORDER RESPONSE: ${res.body}');

    if (res.statusCode != 201) {
      throw Exception('Failed to place order: ${res.body}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
