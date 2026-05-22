import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';
import '../repositories/social_repository.dart';
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

  Future<void> initialize() async {
    await games.load();
  }

  void refresh() => notifyListeners();
}
