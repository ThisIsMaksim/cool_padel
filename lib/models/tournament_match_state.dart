class TournamentMatchState {
  const TournamentMatchState({
    required this.totalPoints,
    this.minPointLead = 2,
    this.servingTeamIndex = 0,
    this.team1Points = 0,
    this.team2Points = 0,
    this.winnerIndex,
  });

  final int totalPoints;
  final int minPointLead;
  final int servingTeamIndex;
  final int team1Points;
  final int team2Points;
  final int? winnerIndex;

  int get receivingTeamIndex => servingTeamIndex == 0 ? 1 : 0;

  int get playedPoints => team1Points + team2Points;

  int get remainingPoints => (totalPoints - playedPoints).clamp(0, totalPoints);

  double get progress => totalPoints == 0 ? 0 : playedPoints / totalPoints;

  bool get isFinished => winnerIndex != null;

  bool _shouldFinish(int t1, int t2) {
    final total = t1 + t2;
    if (total < totalPoints) return false;
    return (t1 - t2).abs() >= minPointLead;
  }

  TournamentMatchState scorePoint(int teamIndex) {
    if (isFinished) return this;

    final newTeam1 = teamIndex == 0 ? team1Points + 1 : team1Points;
    final newTeam2 = teamIndex == 1 ? team2Points + 1 : team2Points;
    final nextServer = servingTeamIndex == 0 ? 1 : 0;

    if (_shouldFinish(newTeam1, newTeam2)) {
      final winner = newTeam1 > newTeam2
          ? 0
          : newTeam2 > newTeam1
              ? 1
              : null;
      return TournamentMatchState(
        totalPoints: totalPoints,
        minPointLead: minPointLead,
        servingTeamIndex: nextServer,
        team1Points: newTeam1,
        team2Points: newTeam2,
        winnerIndex: winner,
      );
    }

    return TournamentMatchState(
      totalPoints: totalPoints,
      minPointLead: minPointLead,
      servingTeamIndex: nextServer,
      team1Points: newTeam1,
      team2Points: newTeam2,
    );
  }

  TournamentMatchState undoLastPoint() {
    if (team1Points == 0 && team2Points == 0) return this;

    if (isFinished) {
      return TournamentMatchState(
        totalPoints: totalPoints,
        minPointLead: minPointLead,
        servingTeamIndex: servingTeamIndex,
        team1Points: team1Points,
        team2Points: team2Points,
      );
    }

    if (team1Points >= team2Points && team1Points > 0) {
      return TournamentMatchState(
        totalPoints: totalPoints,
        minPointLead: minPointLead,
        servingTeamIndex: servingTeamIndex == 0 ? 1 : 0,
        team1Points: team1Points - 1,
        team2Points: team2Points,
      );
    }

    return TournamentMatchState(
      totalPoints: totalPoints,
      minPointLead: minPointLead,
      servingTeamIndex: servingTeamIndex == 0 ? 1 : 0,
      team1Points: team1Points,
      team2Points: team2Points - 1,
    );
  }
}
