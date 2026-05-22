import 'dart:convert';

import '../models/deuce_rule.dart';
import '../models/game.dart';
import '../models/match_config.dart';
import '../models/match_mode.dart';
import '../models/standard_match_state.dart';
import '../models/tournament_match_state.dart';

class GameSerialization {
  static Map<String, dynamic> gameToJson(Game game) => {
        'id': game.id,
        'createdAt': game.createdAt.toIso8601String(),
        'status': game.status.name,
        'config': matchConfigToJson(game.config),
        if (game.standardState != null)
          'standardState': standardStateToJson(game.standardState!),
        if (game.tournamentState != null)
          'tournamentState': tournamentStateToJson(game.tournamentState!),
      };

  static Game gameFromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: GameStatus.values.byName(json['status'] as String),
      config: matchConfigFromJson(json['config'] as Map<String, dynamic>),
      standardState: json['standardState'] != null
          ? standardStateFromJson(json['standardState'] as Map<String, dynamic>)
          : null,
      tournamentState: json['tournamentState'] != null
          ? tournamentStateFromJson(
              json['tournamentState'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static List<Game> gamesFromJsonString(String source) {
    if (source.isEmpty) return [];
    final decoded = jsonDecode(source);
    if (decoded is! List) return [];
    return decoded.whereType<Map<String, dynamic>>().map(gameFromJson).toList();
  }

  static String gamesToJsonString(List<Game> games) {
    return jsonEncode(games.map(gameToJson).toList());
  }

  static Map<String, dynamic> matchConfigToJson(MatchConfig config) => {
        'mode': config.mode.name,
        'team1Name': config.team1Name,
        'team2Name': config.team2Name,
        'participantIds': config.participantIds,
        'setsToWin': config.setsToWin,
        'totalPoints': config.totalPoints,
        'minPointLead': config.minPointLead,
        'deuceRule': config.deuceRule.name,
      };

  static MatchConfig matchConfigFromJson(Map<String, dynamic> json) {
    return MatchConfig(
      mode: MatchMode.values.byName(json['mode'] as String),
      team1Name: json['team1Name'] as String,
      team2Name: json['team2Name'] as String,
      participantIds: (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      setsToWin: json['setsToWin'] as int? ?? 2,
      totalPoints: json['totalPoints'] as int? ?? 50,
      minPointLead: json['minPointLead'] as int? ?? 2,
      deuceRule: json['deuceRule'] != null
          ? DeuceRule.values.byName(json['deuceRule'] as String)
          : DeuceRule.advantage,
    );
  }

  static Map<String, dynamic> setScoreToJson(SetScore score) => {
        'team1Games': score.team1Games,
        'team2Games': score.team2Games,
      };

  static SetScore setScoreFromJson(Map<String, dynamic> json) {
    return SetScore(
      team1Games: json['team1Games'] as int,
      team2Games: json['team2Games'] as int,
    );
  }

  static Map<String, dynamic> standardStateToJson(StandardMatchState state) =>
      {
        'setsToWin': state.setsToWin,
        'deuceRule': state.deuceRule.name,
        'servingTeamIndex': state.servingTeamIndex,
        'completedSets':
            state.completedSets.map(setScoreToJson).toList(growable: false),
        'currentSet': setScoreToJson(state.currentSet),
        'team1Points': state.team1Points,
        'team2Points': state.team2Points,
        'pointPhase': state.pointPhase.name,
        'isTiebreak': state.isTiebreak,
        'winnerIndex': state.winnerIndex,
      };

  static StandardMatchState standardStateFromJson(Map<String, dynamic> json) {
    return StandardMatchState(
      setsToWin: json['setsToWin'] as int,
      deuceRule: json['deuceRule'] != null
          ? DeuceRule.values.byName(json['deuceRule'] as String)
          : DeuceRule.advantage,
      servingTeamIndex: json['servingTeamIndex'] as int? ?? 0,
      completedSets: (json['completedSets'] as List<dynamic>)
          .map((item) => setScoreFromJson(item as Map<String, dynamic>))
          .toList(),
      currentSet: setScoreFromJson(json['currentSet'] as Map<String, dynamic>),
      team1Points: json['team1Points'] as int? ?? 0,
      team2Points: json['team2Points'] as int? ?? 0,
      pointPhase: PointPhase.values.byName(json['pointPhase'] as String),
      isTiebreak: json['isTiebreak'] as bool? ?? false,
      winnerIndex: json['winnerIndex'] as int?,
    );
  }

  static Map<String, dynamic> tournamentStateToJson(
    TournamentMatchState state,
  ) =>
      {
        'totalPoints': state.totalPoints,
        'minPointLead': state.minPointLead,
        'servingTeamIndex': state.servingTeamIndex,
        'team1Points': state.team1Points,
        'team2Points': state.team2Points,
        'winnerIndex': state.winnerIndex,
      };

  static TournamentMatchState tournamentStateFromJson(
    Map<String, dynamic> json,
  ) {
    return TournamentMatchState(
      totalPoints: json['totalPoints'] as int,
      minPointLead: json['minPointLead'] as int? ?? 2,
      servingTeamIndex: json['servingTeamIndex'] as int? ?? 0,
      team1Points: json['team1Points'] as int? ?? 0,
      team2Points: json['team2Points'] as int? ?? 0,
      winnerIndex: json['winnerIndex'] as int?,
    );
  }
}
