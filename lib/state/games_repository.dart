import 'package:flutter/foundation.dart';

import '../models/deuce_rule.dart';
import '../models/game.dart';
import '../models/match_config.dart';
import '../models/match_mode.dart';
import '../models/standard_match_state.dart';
import '../models/tournament_match_state.dart';
import '../services/api_client.dart';
import '../services/wear_sync_service.dart';
import '../storage/game_serialization.dart';
import '../storage/games_storage.dart';

class GamesRepository extends ChangeNotifier {
  GamesRepository({
    required GamesStorage storage,
    ApiClient? api,
    WearSyncService? wearSync,
  })  : _storage = storage,
        _api = api,
        _wearSync = wearSync ?? WearSyncService();

  final GamesStorage _storage;
  final ApiClient? _api;
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
    if (_api?.token != null) {
      try {
        final list = await _api!.getList('/games');
        _games
          ..clear()
          ..addAll(
            list
                .whereType<Map<String, dynamic>>()
                .map(GameSerialization.gameFromJson),
          );
        _isLoaded = true;
        notifyListeners();
        return;
      } catch (_) {}
    }

    final saved = await _storage.loadGames();
    _games
      ..clear()
      ..addAll(saved);
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
    if (_api?.token != null) {
      try {
        final json = await _api!.post('/games', body: {
          'config': GameSerialization.matchConfigToJson(config),
          'servingTeamIndex': servingTeamIndex,
          'servingPlayerIndex': servingPlayerIndex,
        });
        final game = GameSerialization.gameFromJson(json);
        _games.insert(0, game);
        notifyListeners();
        _syncWear(game);
        return game;
      } catch (_) {}
    }

    final game = Game(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      config: config,
      createdAt: DateTime.now(),
      standardState: config.mode == MatchMode.standard
          ? StandardMatchState(
              setsToWin: config.setsToWin,
              deuceRule: config.deuceRule,
              servingTeamIndex: servingTeamIndex,
              servingPlayerIndex: servingPlayerIndex,
            )
          : null,
      tournamentState: config.mode == MatchMode.tournament
          ? TournamentMatchState(
              totalPoints: config.totalPoints,
              minPointLead: config.minPointLead,
              servingTeamIndex: servingTeamIndex,
              servingPlayerIndex: servingPlayerIndex,
            )
          : null,
    );
    _games.insert(0, game);
    notifyListeners();
    _persist();
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
    _persist();
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
    _persist();
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
    _persist();
    _patchDeuceRule(id, rule);
  }

  void removeGame(String id) {
    _games.removeWhere((g) => g.id == id);
    notifyListeners();
    _persist();
    if (_api?.token != null) {
      _api!.delete('/games/$id').ignore();
    }
  }

  void _patchStandardState(String id, StandardMatchState state) {
    if (_api?.token == null) return;
    _api!
        .patch('/games/$id/standard-state', body: {
          'standardState': GameSerialization.standardStateToJson(state),
        })
        .ignore();
  }

  void _patchTournamentState(String id, TournamentMatchState state) {
    if (_api?.token == null) return;
    _api!
        .patch('/games/$id/tournament-state', body: {
          'tournamentState': GameSerialization.tournamentStateToJson(state),
        })
        .ignore();
  }

  void _patchDeuceRule(String id, DeuceRule rule) {
    if (_api?.token == null) return;
    _api!
        .patch('/games/$id/deuce-rule', body: {'deuceRule': rule.name})
        .ignore();
  }

  void _syncWear(Game game) {
    _wearSync.syncActiveGame(game);
  }

  Future<void> _persistQueue = Future.value();

  void _persist() {
    _persistQueue = _persistQueue.then(
      (_) => _storage.saveGames(List.unmodifiable(_games)),
    );
  }

  @visibleForTesting
  Future<void> flushPersistence() => _persistQueue;
}
