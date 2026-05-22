import 'deuce_rule.dart';

class SetScore {
  const SetScore({required this.team1Games, required this.team2Games});

  final int team1Games;
  final int team2Games;

  SetScore copyWith({int? team1Games, int? team2Games}) {
    return SetScore(
      team1Games: team1Games ?? this.team1Games,
      team2Games: team2Games ?? this.team2Games,
    );
  }
}

enum PointPhase { normal, deuce, team1Advantage, team2Advantage }

class StandardMatchState {
  StandardMatchState({
    required this.setsToWin,
    this.deuceRule = DeuceRule.advantage,
    this.servingTeamIndex = 0,
    List<SetScore>? completedSets,
    this.currentSet = const SetScore(team1Games: 0, team2Games: 0),
    this.team1Points = 0,
    this.team2Points = 0,
    this.pointPhase = PointPhase.normal,
    this.isTiebreak = false,
    this.winnerIndex,
  }) : completedSets = List.unmodifiable(completedSets ?? []);

  final int setsToWin;
  final DeuceRule deuceRule;
  final int servingTeamIndex;
  final List<SetScore> completedSets;
  final SetScore currentSet;
  final int team1Points;
  final int team2Points;
  final PointPhase pointPhase;
  final bool isTiebreak;
  final int? winnerIndex;

  int get receivingTeamIndex => servingTeamIndex == 0 ? 1 : 0;

  int get team1Sets =>
      completedSets.where((s) => s.team1Games > s.team2Games).length;

  int get team2Sets =>
      completedSets.where((s) => s.team2Games > s.team1Games).length;

  bool get isFinished => winnerIndex != null;

  bool get isDeuceSituation =>
      pointPhase == PointPhase.deuce ||
      pointPhase == PointPhase.team1Advantage ||
      pointPhase == PointPhase.team2Advantage;

  String formatPoint(int points, int teamIndex) {
    if (isTiebreak) return '$points';

    switch (pointPhase) {
      case PointPhase.deuce:
        return deuceRule == DeuceRule.goldenPoint ? '40' : '40';
      case PointPhase.team1Advantage:
        return teamIndex == 0 ? 'AD' : '40';
      case PointPhase.team2Advantage:
        return teamIndex == 1 ? 'AD' : '40';
      case PointPhase.normal:
        return switch (points) {
          0 => '0',
          1 => '15',
          2 => '30',
          3 => '40',
          _ => '40',
        };
    }
  }

  StandardMatchState scorePoint(int teamIndex) {
    if (isFinished) return this;

    if (isTiebreak) {
      return _scoreTiebreakPoint(teamIndex);
    }

    return _scoreRegularPoint(teamIndex);
  }

  StandardMatchState _scoreRegularPoint(int teamIndex) {
    final isTeam1 = teamIndex == 0;

    if (pointPhase == PointPhase.deuce &&
        deuceRule == DeuceRule.goldenPoint) {
      return _winGame(teamIndex: teamIndex);
    }

    switch (pointPhase) {
      case PointPhase.deuce:
        return copyWith(
          pointPhase:
              isTeam1 ? PointPhase.team1Advantage : PointPhase.team2Advantage,
        );

      case PointPhase.team1Advantage:
        if (isTeam1) {
          return _winGame(teamIndex: 0);
        }
        return copyWith(pointPhase: PointPhase.deuce);

      case PointPhase.team2Advantage:
        if (!isTeam1) {
          return _winGame(teamIndex: 1);
        }
        return copyWith(pointPhase: PointPhase.deuce);

      case PointPhase.normal:
        final myPoints = isTeam1 ? team1Points : team2Points;
        final oppPoints = isTeam1 ? team2Points : team1Points;

        if (myPoints >= 3 && oppPoints < 3) {
          return _winGame(teamIndex: teamIndex);
        }

        if (myPoints == 2 && oppPoints == 3) {
          return copyWith(pointPhase: PointPhase.deuce);
        }

        if (myPoints == 3 && oppPoints == 3) {
          return copyWith(pointPhase: PointPhase.deuce);
        }

        return copyWith(
          team1Points: isTeam1 ? team1Points + 1 : team1Points,
          team2Points: !isTeam1 ? team2Points + 1 : team2Points,
        );
    }
  }

  StandardMatchState _scoreTiebreakPoint(int teamIndex) {
    final newTeam1 = teamIndex == 0 ? team1Points + 1 : team1Points;
    final newTeam2 = teamIndex == 1 ? team2Points + 1 : team2Points;

    final leader = newTeam1 > newTeam2 ? newTeam1 : newTeam2;
    final trailer = newTeam1 > newTeam2 ? newTeam2 : newTeam1;

    if (leader >= 7 && leader - trailer >= 2) {
      return _winSet(
        teamIndex: newTeam1 > newTeam2 ? 0 : 1,
        fromTiebreak: true,
      );
    }

    return copyWith(team1Points: newTeam1, team2Points: newTeam2);
  }

  StandardMatchState _winGame({required int teamIndex}) {
    final newSet = teamIndex == 0
        ? currentSet.copyWith(team1Games: currentSet.team1Games + 1)
        : currentSet.copyWith(team2Games: currentSet.team2Games + 1);

    final t1 = newSet.team1Games;
    final t2 = newSet.team2Games;
    final nextServer = servingTeamIndex == 0 ? 1 : 0;

    if (t1 == 6 && t2 == 6) {
      return copyWith(
        currentSet: newSet,
        team1Points: 0,
        team2Points: 0,
        pointPhase: PointPhase.normal,
        isTiebreak: true,
        servingTeamIndex: nextServer,
      );
    }

    if ((t1 >= 6 || t2 >= 6) && (t1 - t2).abs() >= 2) {
      return _winSet(teamIndex: t1 > t2 ? 0 : 1);
    }

    return copyWith(
      currentSet: newSet,
      team1Points: 0,
      team2Points: 0,
      pointPhase: PointPhase.normal,
      servingTeamIndex: nextServer,
    );
  }

  StandardMatchState _winSet({required int teamIndex, bool fromTiebreak = false}) {
    final finishedSet = fromTiebreak
        ? (teamIndex == 0
            ? currentSet.copyWith(team1Games: 7, team2Games: 6)
            : currentSet.copyWith(team1Games: 6, team2Games: 7))
        : currentSet;

    final newCompleted = [...completedSets, finishedSet];
    final newTeam1Sets =
        newCompleted.where((s) => s.team1Games > s.team2Games).length;
    final newTeam2Sets =
        newCompleted.where((s) => s.team2Games > s.team1Games).length;

    if (newTeam1Sets >= setsToWin || newTeam2Sets >= setsToWin) {
      return copyWith(
        completedSets: newCompleted,
        currentSet: const SetScore(team1Games: 0, team2Games: 0),
        team1Points: 0,
        team2Points: 0,
        pointPhase: PointPhase.normal,
        isTiebreak: false,
        winnerIndex: newTeam1Sets >= setsToWin ? 0 : 1,
      );
    }

    return copyWith(
      completedSets: newCompleted,
      currentSet: const SetScore(team1Games: 0, team2Games: 0),
      team1Points: 0,
      team2Points: 0,
      pointPhase: PointPhase.normal,
      isTiebreak: false,
      servingTeamIndex: teamIndex == 0 ? 1 : 0,
    );
  }

  StandardMatchState updateDeuceRule(DeuceRule rule) {
    if (rule == deuceRule) return this;

    if (rule == DeuceRule.goldenPoint &&
        (pointPhase == PointPhase.team1Advantage ||
            pointPhase == PointPhase.team2Advantage)) {
      return copyWith(deuceRule: rule, pointPhase: PointPhase.deuce);
    }

    return copyWith(deuceRule: rule);
  }

  StandardMatchState undoLastPoint() {
    if (isFinished) {
      return copyWith(winnerIndex: null, clearWinner: true);
    }

    if (isTiebreak) {
      if (team1Points == 0 && team2Points == 0) return this;
      if (team1Points > team2Points) {
        return copyWith(team1Points: team1Points - 1);
      }
      return copyWith(team2Points: team2Points - 1);
    }

    if (pointPhase == PointPhase.team1Advantage) {
      return copyWith(pointPhase: PointPhase.deuce);
    }
    if (pointPhase == PointPhase.team2Advantage) {
      return copyWith(pointPhase: PointPhase.deuce);
    }
    if (pointPhase == PointPhase.deuce) {
      return copyWith(
        pointPhase: PointPhase.normal,
        team1Points: 3,
        team2Points: 3,
      );
    }

    if (team1Points > 0 && team1Points >= team2Points) {
      return copyWith(team1Points: team1Points - 1);
    }
    if (team2Points > 0) {
      return copyWith(team2Points: team2Points - 1);
    }

    return this;
  }

  StandardMatchState copyWith({
    List<SetScore>? completedSets,
    SetScore? currentSet,
    int? team1Points,
    int? team2Points,
    PointPhase? pointPhase,
    bool? isTiebreak,
    int? winnerIndex,
    bool clearWinner = false,
    DeuceRule? deuceRule,
    int? servingTeamIndex,
  }) {
    return StandardMatchState(
      setsToWin: setsToWin,
      deuceRule: deuceRule ?? this.deuceRule,
      servingTeamIndex: servingTeamIndex ?? this.servingTeamIndex,
      completedSets: completedSets ?? this.completedSets,
      currentSet: currentSet ?? this.currentSet,
      team1Points: team1Points ?? this.team1Points,
      team2Points: team2Points ?? this.team2Points,
      pointPhase: pointPhase ?? this.pointPhase,
      isTiebreak: isTiebreak ?? this.isTiebreak,
      winnerIndex: clearWinner ? null : (winnerIndex ?? this.winnerIndex),
    );
  }
}
