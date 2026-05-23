import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';
import '../models/player.dart';
import '../models/tournament.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';

class SocialRepository extends ChangeNotifier {
  SocialRepository(this._prefs, this._api) : _useApi = true;

  SocialRepository.offline(this._prefs)
      : _api = null,
        _useApi = false {
    _tournaments = MockData.tournaments();
    _players = MockData.players;
    _restoreFavorites();
  }

  final SharedPreferences _prefs;
  final ApiClient? _api;
  final bool _useApi;

  static const _favoritesKey = 'favorites_v1';

  List<Tournament> _tournaments = [];
  List<Player> _players = [];
  final Set<String> _favoriteIds = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<Player> get allPlayers => List.unmodifiable(_players);

  List<Player> get ratingList =>
      [..._players]..sort((a, b) => b.rating.compareTo(a.rating));

  List<Tournament> get tournaments => List.unmodifiable(_tournaments);

  List<Tournament> get activeTournaments => _tournaments
      .where((t) => t.status != TournamentStatus.finished)
      .toList();

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<Player> get favorites =>
      _players.where((p) => _favoriteIds.contains(p.id)).toList();

  Future<void> load() async {
    if (!_useApi || _api == null) {
      _isLoaded = true;
      return;
    }

    try {
      final results = await Future.wait([
        _api.getList('/players'),
        _api.getList('/tournaments'),
        _api.getList('/users/me/favorites'),
      ]);

      _players = results[0]
          .whereType<Map<String, dynamic>>()
          .map(Player.fromJson)
          .toList();

      _tournaments = results[1]
          .whereType<Map<String, dynamic>>()
          .map(Tournament.fromJson)
          .toList();

      _favoriteIds
        ..clear()
        ..addAll(
          results[2]
              .whereType<Map<String, dynamic>>()
              .map((p) => p['id'] as String),
        );
    } catch (_) {
      _players = MockData.players;
      _tournaments = MockData.tournaments();
      await _restoreFavorites();
    }

    _isLoaded = true;
    notifyListeners();
  }

  Player? playerById(String id) {
    for (final p in _players) {
      if (p.id == id) return p;
    }
    return null;
  }

  bool isFavorite(String playerId) => _favoriteIds.contains(playerId);

  Future<void> _restoreFavorites() async {
    final raw = _prefs.getStringList(_favoritesKey);
    if (raw != null) {
      _favoriteIds.addAll(raw);
    }
  }

  Future<void> toggleFavorite(String playerId) async {
    if (_useApi && _api != null) {
      try {
        final json =
            await _api.patch('/users/me/favorites/$playerId/toggle');
        final ids = (json['favoriteIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
        _favoriteIds
          ..clear()
          ..addAll(ids);
        notifyListeners();
        return;
      } catch (_) {}
    }

    if (_favoriteIds.contains(playerId)) {
      _favoriteIds.remove(playerId);
    } else {
      _favoriteIds.add(playerId);
    }
    await _prefs.setStringList(_favoritesKey, _favoriteIds.toList());
    notifyListeners();
  }

  Tournament? tournamentById(String id) {
    for (final t in _tournaments) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<String?> registerForTournament({
    required String tournamentId,
    required String userId,
    String? partnerId,
  }) async {
    if (_useApi && _api != null) {
      try {
        final json = await _api.post(
          '/tournaments/$tournamentId/register',
          body: partnerId == null ? {} : {'partnerId': partnerId},
        );
        final updated = Tournament.fromJson(json);
        final index = _tournaments.indexWhere((t) => t.id == tournamentId);
        if (index != -1) {
          _tournaments[index] = updated;
        }
        notifyListeners();
        return null;
      } on ApiException catch (e) {
        return e.message;
      } catch (_) {
        return 'Не удалось записаться на турнир';
      }
    }

    return _registerLocal(
      tournamentId: tournamentId,
      userId: userId,
      partnerId: partnerId,
    );
  }

  String? _registerLocal({
    required String tournamentId,
    required String userId,
    String? partnerId,
  }) {
    final index = _tournaments.indexWhere((t) => t.id == tournamentId);
    if (index == -1) return 'Турнир не найден';

    final tournament = _tournaments[index];
    if (tournament.participantIds.contains(userId)) {
      return 'Вы уже записаны';
    }

    final slotsNeeded = tournament.format == TournamentFormat.doubles ? 2 : 1;
    final idsToAdd = <String>[userId];
    if (partnerId != null) idsToAdd.add(partnerId);

    if (idsToAdd.length < slotsNeeded) {
      return 'Выберите партнёра для парного турнира';
    }

    if (tournament.freeSlots < slotsNeeded) {
      final waitlist = [...tournament.waitlistIds];
      if (!waitlist.contains(userId)) waitlist.add(userId);
      _tournaments[index] = tournament.copyWith(waitlistIds: waitlist);
      notifyListeners();
      return null;
    }

    final participants = [...tournament.participantIds, ...idsToAdd];
    _tournaments[index] = tournament.copyWith(
      participantIds: participants,
      status: participants.length >= tournament.maxParticipants
          ? TournamentStatus.full
          : tournament.status,
    );
    notifyListeners();
    return null;
  }

  List<Tournament> filterTournaments({
    String? day,
    String? level,
    TournamentFormat? format,
    String? club,
  }) {
    return _tournaments.where((t) {
      if (level != null && level != 'Все' && t.level != level) return false;
      if (format != null && t.format != format) return false;
      if (club != null && club != 'Все' && t.club != club) return false;
      if (day != null && day != 'Все') {
        final weekday = _weekdayLabel(t.dateTime.weekday);
        if (weekday != day) return false;
      }
      return true;
    }).toList();
  }

  static String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Пн',
      DateTime.tuesday => 'Вт',
      DateTime.wednesday => 'Ср',
      DateTime.thursday => 'Чт',
      DateTime.friday => 'Пт',
      DateTime.saturday => 'Сб',
      DateTime.sunday => 'Вс',
      _ => '',
    };
  }

  UserProfile? profileForPlayer(Player player) {
    return UserProfile(
      id: player.id,
      name: player.name,
      email: '${player.id}@coolpadel.app',
      rating: player.rating,
      level: player.level,
      club: player.club,
      city: player.city,
      tournamentHistory: _tournaments
          .where((t) => t.participantIds.contains(player.id))
          .map((t) => t.id)
          .toList(),
    );
  }
}
