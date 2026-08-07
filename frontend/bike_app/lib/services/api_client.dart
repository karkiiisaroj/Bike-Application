import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final Map<String, dynamic> body;
  ApiException(this.statusCode, this.body);

  String get firstError {
    if (body.isEmpty) return 'Something went wrong. Please try again.';
    final v = body.values.first;
    if (v is List)
      return v.isNotEmpty ? v.first.toString() : 'Something went wrong.';
    return v.toString();
  }
}

class ApiClient {
  static Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
    bool retry = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = {'Content-Type': 'application/json'};

    if (auth) {
      final token = await TokenStorage.accessToken;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    final encoded = body != null ? jsonEncode(body) : null;
    late http.Response response;

    switch (method) {
      case 'POST':
        response = await http.post(uri, headers: headers, body: encoded);
        break;
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: encoded);
        break;
      default:
        throw UnimplementedError(method);
    }

    if (response.statusCode == 401 && auth && retry) {
      if (await _refreshToken()) {
        return _send(method, path, body: body, auth: auth, retry: false);
      }
    }

    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    }
    throw ApiException(
      response.statusCode,
      decoded is Map<String, dynamic> ? decoded : {},
    );
  }

  static Future<bool> _refreshToken() async {
    final refresh = await TokenStorage.refreshToken;
    if (refresh == null) return false;

    final uri = Uri.parse('${ApiConfig.baseUrl}/accounts/login/refresh/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await TokenStorage.save(access: data['access'], refresh: refresh);
      return true;
    }
    await TokenStorage.clear();
    return false;
  }

  static Future<Map<String, dynamic>> get(String path, {bool auth = true}) =>
      _send('GET', path, auth: auth);
  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) => _send('POST', path, body: body, auth: auth);
  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) => _send('PATCH', path, body: body, auth: auth);
}
