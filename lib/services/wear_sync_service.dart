import '../models/game.dart';

/// Заглушка для синхронизации с Apple Watch / Wear OS.
/// На iOS/Android подключается через platform channel.
class WearSyncService {
  Game? _activeGame;

  Game? get activeGame => _activeGame;

  void syncActiveGame(Game game) {
    _activeGame = game;
  }

  Future<void> scorePointFromWear(int teamIndex) async {
    // Будет связано с GamesRepository через AppState / platform channel.
  }
}
