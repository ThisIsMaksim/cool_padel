import 'package:flutter/foundation.dart';

import '../models/game.dart';
import '../models/match_config.dart';
import '../models/match_mode.dart';
import '../models/standard_match_state.dart';
import '../models/tournament_match_state.dart';
import '../storage/games_storage.dart';

class GamesRepository extends ChangeNotifier {
  GamesRepository({required GamesStorage storage}) : _storage = storage;

  final GamesStorage _storage;
  final List<Game> _games = [];
  bool _isLoaded = false;

  List<Game> get games => List.unmodifiable(_games);

  bool get isLoaded => _isLoaded;

  int get activeCount =>
      _games.where((g) => g.status == GameStatus.inProgress).length;

  Future<void> load() async {
    final saved = await _storage.loadGames();
    _games
      ..clear()
      ..addAll(saved);
    _isLoaded = true;
    notifyListeners();
  }

  Game createGame(MatchConfig config) {
    final game = Game(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      config: config,
      createdAt: DateTime.now(),
      standardState: config.mode == MatchMode.standard
          ? StandardMatchState(setsToWin: config.setsToWin)
          : null,
      tournamentState: config.mode == MatchMode.tournament
          ? TournamentMatchState(totalPoints: config.totalPoints)
          : null,
    );
    _games.insert(0, game);
    notifyListeners();
    _persist();
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
  }

  void removeGame(String id) {
    _games.removeWhere((g) => g.id == id);
    notifyListeners();
    _persist();
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
