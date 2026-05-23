import 'deuce_rule.dart';
import 'game_format.dart';
import 'match_mode.dart';
import 'team_member.dart';

class MatchConfig {
  const MatchConfig({
    required this.mode,
    required this.team1Name,
    required this.team2Name,
    this.gameFormat = GameFormat.doubles2x2,
    this.team1Members = const [],
    this.team2Members = const [],
    this.participantIds = const [],
    this.setsToWin = 2,
    this.totalPoints = 50,
    this.minPointLead = 2,
    this.deuceRule = DeuceRule.advantage,
  });

  final MatchMode mode;
  final String team1Name;
  final String team2Name;
  final GameFormat gameFormat;
  final List<TeamMember> team1Members;
  final List<TeamMember> team2Members;
  final List<String> participantIds;
  final int setsToWin;
  final int totalPoints;
  final int minPointLead;
  final DeuceRule deuceRule;

  List<TeamMember> membersForTeam(int teamIndex) =>
      teamIndex == 0 ? team1Members : team2Members;

  TeamMember? memberAt(int teamIndex, int playerIndex) {
    final members = membersForTeam(teamIndex);
    if (playerIndex < 0 || playerIndex >= members.length) return null;
    return members[playerIndex];
  }

  TeamMember? serverMember(int teamIndex, int playerIndex) =>
      memberAt(teamIndex, playerIndex);

  TeamMember? receiverMember(int servingTeamIndex, int servingPlayerIndex) {
    final server = serverMember(servingTeamIndex, servingPlayerIndex);
    if (server == null) return null;

    final receivingTeam = servingTeamIndex == 0 ? team2Members : team1Members;
    if (receivingTeam.isEmpty) return null;

    if (gameFormat == GameFormat.singles1x1) {
      return receivingTeam.first;
    }

    if (server.side != null) {
      for (final member in receivingTeam) {
        if (member.side == server.side) return member;
      }
    }

    return receivingTeam.first;
  }

  static String teamLabel(List<TeamMember> members) {
    if (members.isEmpty) return 'Команда';
    return members.map((m) => m.shortName).join(' / ');
  }

  MatchConfig copyWith({
    MatchMode? mode,
    String? team1Name,
    String? team2Name,
    GameFormat? gameFormat,
    List<TeamMember>? team1Members,
    List<TeamMember>? team2Members,
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
      gameFormat: gameFormat ?? this.gameFormat,
      team1Members: team1Members ?? this.team1Members,
      team2Members: team2Members ?? this.team2Members,
      participantIds: participantIds ?? this.participantIds,
      setsToWin: setsToWin ?? this.setsToWin,
      totalPoints: totalPoints ?? this.totalPoints,
      minPointLead: minPointLead ?? this.minPointLead,
      deuceRule: deuceRule ?? this.deuceRule,
    );
  }
}
