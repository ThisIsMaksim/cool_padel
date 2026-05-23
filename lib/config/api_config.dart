import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const tokenKey = 'auth_token_v1';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv.endsWith('/') ? fromEnv.substring(0, fromEnv.length - 1) : fromEnv;
    }
    if (kIsWeb) {
      return '${Uri.base.origin}/api/v1';
    }
    return 'http://127.0.0.1:3000/api/v1';
  }
}
