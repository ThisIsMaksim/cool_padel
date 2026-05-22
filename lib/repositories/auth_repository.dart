import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';
import '../models/user_profile.dart';

class AuthRepository extends ChangeNotifier {
  AuthRepository(this._prefs);

  static const _sessionKey = 'auth_session_v1';

  final SharedPreferences _prefs;
  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  static Future<AuthRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = AuthRepository(prefs);
    await repo._restoreSession();
    return repo;
  }

  Future<void> _restoreSession() async {
    final raw = _prefs.getString(_sessionKey);
    if (raw == null) return;

    final parts = raw.split('|');
    if (parts.length < 2) return;

    _currentUser = MockData.demoUser(email: parts[0], name: parts[1]);
    notifyListeners();
  }

  Future<String?> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (email.trim().isEmpty || password.length < 4) {
      return 'Введите email и пароль (мин. 4 символа)';
    }

    _currentUser = MockData.demoUser(
      email: email.trim(),
      name: email.split('@').first.replaceAll('.', ' ').split(' ').map((p) {
        if (p.isEmpty) return p;
        return '${p[0].toUpperCase()}${p.substring(1)}';
      }).join(' '),
    );

    await _prefs.setString(_sessionKey, '${_currentUser!.email}|${_currentUser!.name}');
    notifyListeners();
    return null;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (name.trim().length < 2) return 'Введите имя';
    if (!email.contains('@')) return 'Некорректный email';
    if (password.length < 6) return 'Пароль минимум 6 символов';

    _currentUser = MockData.demoUser(email: email.trim(), name: name.trim());
    await _prefs.setString(_sessionKey, '${_currentUser!.email}|${_currentUser!.name}');
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove(_sessionKey);
    notifyListeners();
  }
}
