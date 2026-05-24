import 'package:flutter/foundation.dart';

import '../models/player.dart';
import '../models/tournament.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';

class SocialRepository extends ChangeNotifier {
  SocialRepository(this._api);

  final ApiClient _api;

  List<Tournament> _tournaments = [];
  List<Player> _players = [];
  final Set<String> _favoriteIds = {};
  bool _isLoaded = false;
  String? _loadError;

  bool get isLoaded => _isLoaded;

  String? get loadError => _loadError;

  List<Player> get allPlayers => List.unmodifiable(_players);

  List<Player> get ratingList =>
      [..._players]..sort((a, b) => b.rating.compareTo(a.rating));

  List<Tournament> get tournaments => List.unmodifiable(_tournaments);

  List<Tournament> get myTournaments => _tournaments
      .where((t) => t.organizerId == _myPublicId)
      .toList();

  String? _myPublicId;

  List<Tournament> get activeTournaments => _tournaments
      .where((t) => t.status != TournamentStatus.finished)
      .toList();

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<Player> get favorites =>
      _players.where((p) => _favoriteIds.contains(p.id)).toList();

  Future<void> load({String? myPublicId}) async {
    _requireAuth();
    _myPublicId = myPublicId;

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

    _loadError = null;
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

  Future<void> toggleFavorite(String playerId) async {
    _requireAuth();
    final json = await _api.patch('/users/me/favorites/$playerId/toggle');
    final ids = (json['favoriteIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    _favoriteIds
      ..clear()
      ..addAll(ids);
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
    _requireAuth();
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
    }
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

  List<String> get tournamentClubs {
    final clubs = _tournaments.map((t) => t.club).toSet().toList()..sort();
    return clubs;
  }

  Future<(String?, Tournament?)> createTournament({
    required String title,
    required String description,
    required String club,
    required String address,
    required DateTime dateTime,
    required String level,
    required TournamentFormat format,
    required int maxParticipants,
  }) async {
    _requireAuth();
    try {
      final json = await _api.post('/tournaments', body: {
        'title': title,
        'description': description,
        'club': club,
        'address': address,
        'dateTime': dateTime.toUtc().toIso8601String(),
        'level': level,
        'format': format.name,
        'maxParticipants': maxParticipants,
      });
      final created = Tournament.fromJson(json);
      _tournaments = [..._tournaments, created]
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
      return (null, created);
    } on ApiException catch (e) {
      return (e.message, null);
    }
  }

  void _requireAuth() {
    if (_api.token == null) {
      throw ApiException('Требуется авторизация');
    }
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
