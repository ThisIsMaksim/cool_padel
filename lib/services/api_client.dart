import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final String _baseUrl;
  String? _token;

  String? get token => _token;

  void setToken(String? token) => _token = token;

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
    );
    return _decodeObject(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
    );
    final decoded = _decode(response);
    if (decoded is! List) {
      throw ApiException('Expected list response');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Future<void> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
    );
    if (response.statusCode >= 400) {
      throw ApiException(_errorMessage(response), statusCode: response.statusCode);
    }
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(_errorMessage(response), statusCode: response.statusCode);
    }
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = _decode(response);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {};
  }

  String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        final message = body['message'];
        if (message is List) {
          return message.join(', ');
        }
        return message.toString();
      }
    } catch (_) {}
    return 'Ошибка API (${response.statusCode})';
  }
}
