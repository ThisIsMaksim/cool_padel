import 'package:flutter/foundation.dart';

import '../models/game.dart';
import '../models/match_config.dart';
import '../models/match_stats.dart';
import '../models/deuce_rule.dart';
import '../models/standard_match_state.dart';
import '../models/tournament_match_state.dart';
import '../services/api_client.dart';
import '../services/offline_game_sync.dart';
import '../services/wear_sync_service.dart';
import '../storage/game_serialization.dart';

class GamesRepository extends ChangeNotifier {
  GamesRepository({
    required ApiClient api,
    required OfflineGameSync offlineSync,
    WearSyncService? wearSync,
  })  : _api = api,
        _offlineSync = offlineSync,
        _wearSync = wearSync ?? WearSyncService();

  final ApiClient _api;
  final OfflineGameSync _offlineSync;
  final WearSyncService _wearSync;
  final List<Game> _games = [];
  MatchStats _stats = MatchStats.empty();
  bool _isLoaded = false;

  List<Game> get games => List.unmodifiable(_games);

  List<Game> get activeGames =>
      _games.where((g) => g.status == GameStatus.inProgress).toList();

  List<Game> get finishedGames =>
      _games.where((g) => g.status == GameStatus.finished).toList();

  MatchStats get stats => _stats;

  bool get isLoaded => _isLoaded;

  int get activeCount => activeGames.length;

  Future<void> load() async {
    _requireAuth();
    await _flushOfflineQueue();
    final results = await Future.wait([
      _api.getList('/games'),
      _api.get('/games/stats'),
    ]);
    _games
      ..clear()
      ..addAll(
        (results[0] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(GameSerialization.gameFromJson),
      );
    _stats = MatchStats.fromJson(results[1] as Map<String, dynamic>);
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

    final wasFinished = _games[index].status == GameStatus.finished;
    _games[index] = _games[index].copyWith(
      standardState: state,
      status: state.isFinished ? GameStatus.finished : GameStatus.inProgress,
    );
    notifyListeners();
    _syncWear(_games[index]);
    _patch(
      id,
      '/games/$id/standard-state',
      {'standardState': GameSerialization.standardStateToJson(state)},
    );
    if (state.isFinished && !wasFinished) {
      _reloadStats();
      // Profile rating updates on server after match finish.
    }
  }

  void updateTournamentState(String id, TournamentMatchState state) {
    final index = _games.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final wasFinished = _games[index].status == GameStatus.finished;
    _games[index] = _games[index].copyWith(
      tournamentState: state,
      status: state.isFinished ? GameStatus.finished : GameStatus.inProgress,
    );
    notifyListeners();
    _syncWear(_games[index]);
    _patch(
      id,
      '/games/$id/tournament-state',
      {'tournamentState': GameSerialization.tournamentStateToJson(state)},
    );
    if (state.isFinished && !wasFinished) {
      _reloadStats();
      // Profile rating updates on server after match finish.
    }
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
    _patch(id, '/games/$id/deuce-rule', {'deuceRule': rule.name});
  }

  Future<void> removeGame(String id) async {
    _requireAuth();
    await _api.delete('/games/$id');
    _games.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  Future<void> _reloadStats() async {
    try {
      final json = await _api.get('/games/stats');
      _stats = MatchStats.fromJson(json);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _flushOfflineQueue() async {
    var queue = _offlineSync.loadQueue();
    if (queue.isEmpty) return;

    final remaining = <PendingGamePatch>[];
    for (final patch in queue) {
      try {
        await _api.patch(patch.path, body: patch.body);
      } catch (_) {
        remaining.add(patch);
      }
    }
    await _offlineSync.replaceQueue(remaining);
  }

  void _patch(String id, String path, Map<String, dynamic> body) {
    _api.patch(path, body: body).then((_) {}).catchError((_) async {
      await _offlineSync.enqueue(
        PendingGamePatch(gameId: id, path: path, body: body),
      );
    });
  }

  void _requireAuth() {
    if (_api.token == null) {
      throw ApiException('Требуется авторизация');
    }
  }

  void _syncWear(Game game) {
    _wearSync.syncActiveGame(game);
  }
}
