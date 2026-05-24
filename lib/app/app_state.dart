import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/open_matches_repository.dart';
import '../repositories/social_repository.dart';
import '../services/api_client.dart';
import '../state/games_repository.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.auth,
    required this.games,
    required this.social,
    required this.openMatches,
    required this.notifications,
  });

  final AuthRepository auth;
  final GamesRepository games;
  final SocialRepository social;
  final OpenMatchesRepository openMatches;
  final NotificationsRepository notifications;

  String? bootstrapError;
  String? pendingTournamentId;

  void setPendingTournamentId(String? id) {
    pendingTournamentId = id;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (!auth.isAuthenticated) return;
    await _loadRemoteData();
  }

  Future<void> onAuthenticated() async {
    bootstrapError = null;
    await _loadRemoteData();
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await _loadRemoteData();
    notifyListeners();
  }

  Future<void> afterGameFinished() async {
    await Future.wait([
      auth.refreshProfile(),
      games.load(),
    ]);
    notifyListeners();
  }

  Future<void> _loadRemoteData() async {
    try {
      final userId = auth.currentUser?.id;
      await Future.wait([
        games.load(),
        social.load(myPublicId: userId),
        openMatches.load(),
        notifications.load(),
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
