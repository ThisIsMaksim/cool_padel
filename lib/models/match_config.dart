import 'match_mode.dart';

class MatchConfig {
  const MatchConfig({
    required this.mode,
    required this.team1Name,
    required this.team2Name,
    this.setsToWin = 2,
    this.totalPoints = 50,
  });

  final MatchMode mode;
  final String team1Name;
  final String team2Name;
  final int setsToWin;
  final int totalPoints;

  MatchConfig copyWith({
    MatchMode? mode,
    String? team1Name,
    String? team2Name,
    int? setsToWin,
    int? totalPoints,
  }) {
    return MatchConfig(
      mode: mode ?? this.mode,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      setsToWin: setsToWin ?? this.setsToWin,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
