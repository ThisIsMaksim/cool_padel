import 'package:flutter/foundation.dart';

import '../models/deuce_rule.dart';
import '../models/game.dart';
import '../models/match_config.dart';
import '../models/standard_match_state.dart';
import '../models/tournament_match_state.dart';
import '../services/api_client.dart';
import '../services/wear_sync_service.dart';
import '../storage/game_serialization.dart';

class GamesRepository extends ChangeNotifier {
  GamesRepository({
    required ApiClient api,
    WearSyncService? wearSync,
  })  : _api = api,
        _wearSync = wearSync ?? WearSyncService();

  final ApiClient _api;
  final WearSyncService _wearSync;
  final List<Game> _games = [];
  bool _isLoaded = false;

  List<Game> get games => List.unmodifiable(_games);

  List<Game> get activeGames =>
      _games.where((g) => g.status == GameStatus.inProgress).toList();

  List<Game> get finishedGames =>
      _games.where((g) => g.status == GameStatus.finished).toList();

  bool get isLoaded => _isLoaded;

  int get activeCount => activeGames.length;

  Future<void> load() async {
    _requireAuth();
    final list = await _api.getList('/games');
    _games
      ..clear()
      ..addAll(
        list.whereType<Map<String, dynamic>>().map(GameSerialization.gameFromJson),
      );
    _isLoaded = true;
    notifyListeners();
  }

  Game? gameById(String id) {
    for (final g in _games) {
      if (g.id == id) return g;
    }
    return null;
  }

  Future<Game> createGame(
    MatchConfig config, {
    int servingTeamIndex = 0,
    int servingPlayerIndex = 0,
  }) async {
    _requireAuth();
    final json = await _api.post('/games', body: {
      'config': GameSerialization.matchConfigToJson(config),
      'servingTeamIndex': servingTeamIndex,
      'servingPlayerIndex': servingPlayerIndex,
    });
    final game = GameSerialization.gameFromJson(json);
    _games.insert(0, game);
    notifyListeners();
    _syncWear(game);
    return game;
  }

  void updateStandardState(String id, StandardMatchState state) {
    final index = _games.indexWhere((g) => g.id == id);
    if (index == -1) return;

    _games[index] = _games[index].copyWith(
      standardState: state,
      status: state.isFinished ? GameStatus.finished : GameStatus.inProgress,
    );
    notifyListeners();
    _syncWear(_games[index]);
    _patchStandardState(id, state);
  }

  void updateTournamentState(String id, TournamentMatchState state) {
    final index = _games.indexWhere((g) => g.id == id);
    if (index == -1) return;

    _games[index] = _games[index].copyWith(
      tournamentState: state,
      status: state.isFinished ? GameStatus.finished : GameStatus.inProgress,
    );
    notifyListeners();
    _syncWear(_games[index]);
    _patchTournamentState(id, state);
  }

  void updateDeuceRule(String id, DeuceRule rule) {
    final index = _games.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final game = _games[index];
    if (game.standardState == null) return;

    final newConfig = game.config.copyWith(deuceRule: rule);
    final newState = game.standardState!.updateDeuceRule(rule);

    _games[index] = Game(
      id: game.id,
      config: newConfig,
      createdAt: game.createdAt,
      status: game.status,
      standardState: newState,
      tournamentState: game.tournamentState,
    );
    notifyListeners();
    _patchDeuceRule(id, rule);
  }

  Future<void> removeGame(String id) async {
    _requireAuth();
    await _api.delete('/games/$id');
    _games.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  void _requireAuth() {
    if (_api.token == null) {
      throw ApiException('Требуется авторизация');
    }
  }

  void _patchStandardState(String id, StandardMatchState state) {
    _api
        .patch('/games/$id/standard-state', body: {
          'standardState': GameSerialization.standardStateToJson(state),
        })
        .ignore();
  }

  void _patchTournamentState(String id, TournamentMatchState state) {
    _api
        .patch('/games/$id/tournament-state', body: {
          'tournamentState': GameSerialization.tournamentStateToJson(state),
        })
        .ignore();
  }

  void _patchDeuceRule(String id, DeuceRule rule) {
    _api
        .patch('/games/$id/deuce-rule', body: {'deuceRule': rule.name})
        .ignore();
  }

  void _syncWear(Game game) {
    _wearSync.syncActiveGame(game);
  }
}
