import 'package:shared_preferences/shared_preferences.dart';

import '../models/game.dart';
import 'game_serialization.dart';

abstract class GamesStorage {
  Future<List<Game>> loadGames();

  Future<void> saveGames(List<Game> games);
}

class SharedPreferencesGamesStorage implements GamesStorage {
  SharedPreferencesGamesStorage(this._prefs);

  static const _storageKey = 'games_v1';

  final SharedPreferences _prefs;

  static Future<SharedPreferencesGamesStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesGamesStorage(prefs);
  }

  @override
  Future<List<Game>> loadGames() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    return GameSerialization.gamesFromJsonString(raw);
  }

  @override
  Future<void> saveGames(List<Game> games) async {
    await _prefs.setString(
      _storageKey,
      GameSerialization.gamesToJsonString(games),
    );
  }
}

class InMemoryGamesStorage implements GamesStorage {
  String? _raw;

  @override
  Future<List<Game>> loadGames() async {
    if (_raw == null || _raw!.isEmpty) return [];
    return GameSerialization.gamesFromJsonString(_raw!);
  }

  @override
  Future<void> saveGames(List<Game> games) async {
    _raw = GameSerialization.gamesToJsonString(games);
  }
}
