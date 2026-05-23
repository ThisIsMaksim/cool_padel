import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';
import '../repositories/social_repository.dart';
import '../services/api_client.dart';
import '../state/games_repository.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.auth,
    required this.games,
    required this.social,
  });

  final AuthRepository auth;
  final GamesRepository games;
  final SocialRepository social;

  String? bootstrapError;

  Future<void> initialize() async {
    if (!auth.isAuthenticated) return;
    await _loadRemoteData();
  }

  Future<void> onAuthenticated() async {
    bootstrapError = null;
    await _loadRemoteData();
    notifyListeners();
  }

  Future<void> _loadRemoteData() async {
    try {
      await Future.wait([
        games.load(),
        social.load(),
      ]);
      bootstrapError = null;
    } on ApiException catch (e) {
      bootstrapError = e.message;
    } catch (_) {
      bootstrapError = 'Не удалось загрузить данные с сервера';
    }
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
