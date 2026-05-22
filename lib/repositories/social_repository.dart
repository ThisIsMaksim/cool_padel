import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';
import '../models/player.dart';
import '../models/tournament.dart';
import '../models/user_profile.dart';

class SocialRepository extends ChangeNotifier {
  SocialRepository(this._prefs) {
    _tournaments = MockData.tournaments();
    _restoreFavorites();
  }

  static const _favoritesKey = 'favorites_v1';

  final SharedPreferences _prefs;
  late List<Tournament> _tournaments;
  final Set<String> _favoriteIds = {};

  List<Player> get allPlayers => MockData.players;

  List<Player> get ratingList =>
      [...MockData.players]..sort((a, b) => b.rating.compareTo(a.rating));

  List<Tournament> get tournaments => List.unmodifiable(_tournaments);

  List<Tournament> get activeTournaments => _tournaments
      .where((t) => t.status != TournamentStatus.finished)
      .toList();

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<Player> get favorites =>
      allPlayers.where((p) => _favoriteIds.contains(p.id)).toList();

  Player? playerById(String id) {
    for (final p in allPlayers) {
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

  String? registerForTournament({
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
