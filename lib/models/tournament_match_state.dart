class TournamentMatchState {
  TournamentMatchState({
    required this.totalPoints,
    this.minPointLead = 2,
    this.servingTeamIndex = 0,
    this.servingPlayerIndex = 0,
    int? firstServingTeamIndex,
    this.team1Points = 0,
    this.team2Points = 0,
    this.winnerIndex,
    List<TournamentMatchState>? history,
  })  : firstServingTeamIndex =
            firstServingTeamIndex ?? servingTeamIndex,
        history = List.unmodifiable(history ?? []);

  final int totalPoints;
  final int minPointLead;
  final int servingTeamIndex;
  final int servingPlayerIndex;
  final int firstServingTeamIndex;
  final int team1Points;
  final int team2Points;
  final int? winnerIndex;
  final List<TournamentMatchState> history;

  int get receivingTeamIndex => servingTeamIndex == 0 ? 1 : 0;

  int get playedPoints => team1Points + team2Points;

  int get remainingPoints => (totalPoints - playedPoints).clamp(0, totalPoints);

  double get progress => totalPoints == 0 ? 0 : playedPoints / totalPoints;

  bool get isFinished => winnerIndex != null;

  bool get canUndo => history.isNotEmpty;

  bool _shouldFinish(int t1, int t2) {
    final total = t1 + t2;
    if (total < totalPoints) return false;
    return (t1 - t2).abs() >= minPointLead;
  }

  ({int teamIndex, int playerIndex}) _nextServer(int pointsPlayed) {
    final nextTeam = pointsPlayed.isEven
        ? firstServingTeamIndex
        : (1 - firstServingTeamIndex);
    final serveOrdinal = nextTeam == firstServingTeamIndex
        ? (pointsPlayed ~/ 2) + 1
        : ((pointsPlayed + 1) ~/ 2);
    return (
      teamIndex: nextTeam,
      playerIndex: (serveOrdinal - 1) % 2,
    );
  }

  TournamentMatchState scorePoint(int teamIndex) {
    if (isFinished) return this;

    final newTeam1 = teamIndex == 0 ? team1Points + 1 : team1Points;
    final newTeam2 = teamIndex == 1 ? team2Points + 1 : team2Points;
    final played = newTeam1 + newTeam2;
    final nextServer = _nextServer(played);

    TournamentMatchState next;
    if (_shouldFinish(newTeam1, newTeam2)) {
      final winner = newTeam1 > newTeam2
          ? 0
          : newTeam2 > newTeam1
              ? 1
              : null;
      next = TournamentMatchState(
        totalPoints: totalPoints,
        minPointLead: minPointLead,
        firstServingTeamIndex: firstServingTeamIndex,
        servingTeamIndex: nextServer.teamIndex,
        servingPlayerIndex: nextServer.playerIndex,
        team1Points: newTeam1,
        team2Points: newTeam2,
        winnerIndex: winner,
      );
    } else {
      next = TournamentMatchState(
        totalPoints: totalPoints,
        minPointLead: minPointLead,
        firstServingTeamIndex: firstServingTeamIndex,
        servingTeamIndex: nextServer.teamIndex,
        servingPlayerIndex: nextServer.playerIndex,
        team1Points: newTeam1,
        team2Points: newTeam2,
      );
    }

    return next._appendHistory(this);
  }

  TournamentMatchState _appendHistory(TournamentMatchState previous) {
    return copyWith(history: [...previous.history, previous.withoutHistory()]);
  }

  TournamentMatchState withoutHistory() => copyWith(clearHistory: true);

  TournamentMatchState undoLastPoint() {
    if (history.isEmpty) return this;
    final previous = history.last;
    return previous.copyWith(history: history.sublist(0, history.length - 1));
  }

  TournamentMatchState copyWith({
    int? totalPoints,
    int? minPointLead,
    int? servingTeamIndex,
    int? servingPlayerIndex,
    int? firstServingTeamIndex,
    int? team1Points,
    int? team2Points,
    int? winnerIndex,
    bool clearWinner = false,
    List<TournamentMatchState>? history,
    bool clearHistory = false,
  }) {
    return TournamentMatchState(
      totalPoints: totalPoints ?? this.totalPoints,
      minPointLead: minPointLead ?? this.minPointLead,
      servingTeamIndex: servingTeamIndex ?? this.servingTeamIndex,
      servingPlayerIndex: servingPlayerIndex ?? this.servingPlayerIndex,
      firstServingTeamIndex:
          firstServingTeamIndex ?? this.firstServingTeamIndex,
      team1Points: team1Points ?? this.team1Points,
      team2Points: team2Points ?? this.team2Points,
      winnerIndex: clearWinner ? null : (winnerIndex ?? this.winnerIndex),
      history: clearHistory ? const [] : (history ?? this.history),
    );
  }
}
