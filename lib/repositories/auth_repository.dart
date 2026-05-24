import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/account_type.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';

class AuthRepository extends ChangeNotifier {
  AuthRepository(this._prefs, this._api);

  final SharedPreferences _prefs;
  final ApiClient _api;
  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  static Future<AuthRepository> create({required ApiClient api}) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = AuthRepository(prefs, api);
    await repo._restoreSession();
    return repo;
  }

  Future<void> _restoreSession() async {
    final token = _prefs.getString(ApiConfig.tokenKey);
    if (token == null) return;

    _api.setToken(token);
    try {
      final json = await _api.get('/auth/me');
      _currentUser = UserProfile.fromJson(json);
      notifyListeners();
    } catch (_) {
      await _clearSession();
    }
  }

  Future<String?> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.length < 4) {
      return 'Введите email и пароль (мин. 4 символа)';
    }

    try {
      final json = await _api.post('/auth/login', body: {
        'email': email.trim(),
        'password': password,
      });
      await _applyAuthResponse(json);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Не удалось войти. Проверьте подключение к серверу.';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required AccountType accountType,
  }) async {
    if (name.trim().length < 2) {
      return accountType == AccountType.club
          ? 'Введите название клуба'
          : 'Введите имя';
    }
    if (!email.contains('@')) return 'Некорректный email';
    if (password.length < 6) return 'Пароль минимум 6 символов';

    try {
      final json = await _api.post('/auth/register', body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'accountType': accountType.apiValue,
      });
      await _applyAuthResponse(json);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Не удалось зарегистрироваться. Проверьте подключение к серверу.';
    }
  }

  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_api.token == null) return;
    try {
      final json = await _api.get('/users/me');
      _currentUser = UserProfile.fromJson(json);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _applyAuthResponse(Map<String, dynamic> json) async {
    final token = json['accessToken'] as String;
    _api.setToken(token);
    await _prefs.setString(ApiConfig.tokenKey, token);
    _currentUser = UserProfile.fromJson(json['user'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> _clearSession() async {
    _currentUser = null;
    _api.setToken(null);
    await _prefs.remove(ApiConfig.tokenKey);
  }
}
