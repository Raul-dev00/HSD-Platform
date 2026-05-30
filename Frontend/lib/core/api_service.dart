import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_manager.dart';
import 'constants.dart';

class ApiService {
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await AuthManager.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Uri _uri(String path, [Map<String, String?>? params]) {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    if (params != null) {
      final cleaned = Map<String, String>.fromEntries(
        params.entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value!)),
      );
      return uri.replace(queryParameters: cleaned);
    }
    return uri;
  }

  // GET
  static Future<dynamic> get(String path,
      {Map<String, String?>? params, bool auth = true}) async {
    final response = await http.get(
      _uri(path, params),
      headers: await _headers(auth: auth),
    );
    return _handle(response);
  }

  // POST
  static Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final response = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  // PUT
  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  // DELETE
  static Future<void> delete(String path) async {
    final response = await http.delete(
      _uri(path),
      headers: await _headers(),
    );
    if (response.statusCode >= 400) {
      _throwError(response);
    }
  }

  static dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    _throwError(response);
  }

  static void _throwError(http.Response response) {
    String message = 'Sunucu hatası (${response.statusCode})';
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      message = body['message'] ?? message;
    } catch (_) {}
    throw ApiException(message, response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
