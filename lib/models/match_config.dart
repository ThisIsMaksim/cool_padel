import 'deuce_rule.dart';
import 'match_mode.dart';

class MatchConfig {
  const MatchConfig({
    required this.mode,
    required this.team1Name,
    required this.team2Name,
    this.participantIds = const [],
    this.setsToWin = 2,
    this.totalPoints = 50,
    this.minPointLead = 2,
    this.deuceRule = DeuceRule.advantage,
  });

  final MatchMode mode;
  final String team1Name;
  final String team2Name;
  final List<String> participantIds;
  final int setsToWin;
  final int totalPoints;
  final int minPointLead;
  final DeuceRule deuceRule;

  MatchConfig copyWith({
    MatchMode? mode,
    String? team1Name,
    String? team2Name,
    List<String>? participantIds,
    int? setsToWin,
    int? totalPoints,
    int? minPointLead,
    DeuceRule? deuceRule,
  }) {
    return MatchConfig(
      mode: mode ?? this.mode,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      participantIds: participantIds ?? this.participantIds,
      setsToWin: setsToWin ?? this.setsToWin,
      totalPoints: totalPoints ?? this.totalPoints,
      minPointLead: minPointLead ?? this.minPointLead,
      deuceRule: deuceRule ?? this.deuceRule,
    );
  }
}
