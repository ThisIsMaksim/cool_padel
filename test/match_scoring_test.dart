import 'package:cool_padel/models/deuce_rule.dart';
import 'package:cool_padel/models/standard_match_state.dart';
import 'package:cool_padel/models/tournament_match_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StandardMatchState', () {
    test('advances points 0-15-30-40', () {
      var state = StandardMatchState(setsToWin: 2);
      state = state.scorePoint(0);
      expect(state.formatPoint(state.team1Points, 0), '15');
      state = state.scorePoint(0);
      expect(state.formatPoint(state.team1Points, 0), '30');
      state = state.scorePoint(0);
      expect(state.formatPoint(state.team1Points, 0), '40');
    });

    test('wins game at 40 when opponent below 40', () {
      var state = StandardMatchState(setsToWin: 2);
      state = state.scorePoint(0);
      state = state.scorePoint(0);
      state = state.scorePoint(0);
      state = state.scorePoint(0);
      expect(state.currentSet.team1Games, 1);
      expect(state.team1Points, 0);
    });

    test('handles deuce and advantage', () {
      var state = StandardMatchState(setsToWin: 2);
      for (var i = 0; i < 3; i++) {
        state = state.scorePoint(0);
        state = state.scorePoint(1);
      }
      expect(state.pointPhase, PointPhase.deuce);

      state = state.scorePoint(0);
      expect(state.pointPhase, PointPhase.team1Advantage);

      state = state.scorePoint(1);
      expect(state.pointPhase, PointPhase.deuce);
    });

    test('golden point only after returning from advantage to deuce', () {
      var state = StandardMatchState(
        setsToWin: 2,
        deuceRule: DeuceRule.goldenPoint,
      );

      for (var i = 0; i < 3; i++) {
        state = state.scorePoint(0);
        state = state.scorePoint(1);
      }
      expect(state.pointPhase, PointPhase.deuce);
      expect(state.goldenPointNext, isFalse);

      state = state.scorePoint(0);
      expect(state.pointPhase, PointPhase.team1Advantage);

      state = state.scorePoint(1);
      expect(state.pointPhase, PointPhase.deuce);
      expect(state.goldenPointNext, isTrue);
      expect(state.formatPoint(state.team1Points, 0), 'GP');

      state = state.scorePoint(1);
      expect(state.currentSet.team2Games, 1);
      expect(state.pointPhase, PointPhase.normal);
      expect(state.goldenPointNext, isFalse);
    });

    test('first deuce with golden point rule still uses advantage', () {
      var state = StandardMatchState(
        setsToWin: 2,
        deuceRule: DeuceRule.goldenPoint,
      );

      for (var i = 0; i < 3; i++) {
        state = state.scorePoint(0);
        state = state.scorePoint(1);
      }

      state = state.scorePoint(0);
      expect(state.pointPhase, PointPhase.team1Advantage);
      expect(state.currentSet.team1Games, 0);
    });

    test('match finishes when team wins required sets', () {
      var state = StandardMatchState(setsToWin: 2);

      for (var set = 0; set < 2; set++) {
        for (var game = 0; game < 6; game++) {
          for (var point = 0; point < 4; point++) {
            state = state.scorePoint(0);
          }
        }
      }

      expect(state.isFinished, isTrue);
      expect(state.winnerIndex, 0);
      expect(state.team1Sets, 2);
    });

    test('undo reverts finished game', () {
      var state = StandardMatchState(setsToWin: 2);
      for (var point = 0; point < 4; point++) {
        state = state.scorePoint(0);
      }
      expect(state.currentSet.team1Games, 1);

      state = state.undoLastPoint();
      expect(state.currentSet.team1Games, 0);
      expect(state.team1Points, 3);
    });

    test('undo reverts match win', () {
      var state = StandardMatchState(setsToWin: 1);
      for (var game = 0; game < 6; game++) {
        for (var point = 0; point < 4; point++) {
          state = state.scorePoint(0);
        }
      }
      expect(state.isFinished, isTrue);

      state = state.undoLastPoint();
      expect(state.isFinished, isFalse);
      expect(state.team1Sets, 0);
      expect(state.currentSet.team1Games, 5);
    });

    test('alternates serving player every point within a game', () {
      var state = StandardMatchState(setsToWin: 2);
      expect(state.servingPlayerIndex, 0);

      state = state.scorePoint(0);
      expect(state.servingPlayerIndex, 1);

      state = state.scorePoint(0);
      expect(state.servingPlayerIndex, 0);

      state = state.scorePoint(1);
      expect(state.servingPlayerIndex, 1);
    });
  });

  group('TournamentMatchState', () {
    test('ends when total points reached with min lead', () {
      var state = TournamentMatchState(totalPoints: 10, minPointLead: 2);
      for (var i = 0; i < 4; i++) {
        state = state.scorePoint(0);
      }
      for (var i = 0; i < 5; i++) {
        state = state.scorePoint(1);
      }
      expect(state.playedPoints, 9);
      expect(state.isFinished, isFalse);

      state = state.scorePoint(1);
      expect(state.playedPoints, 10);
      expect(state.isFinished, isTrue);
      expect(state.winnerIndex, 1);
    });

    test('one ball equals one point', () {
      var state = TournamentMatchState(totalPoints: 20);
      state = state.scorePoint(0);
      expect(state.team1Points, 1);
      expect(state.team2Points, 0);
    });

    test('undo reverts match finish', () {
      var state = TournamentMatchState(totalPoints: 10, minPointLead: 2);
      for (var i = 0; i < 4; i++) {
        state = state.scorePoint(0);
      }
      for (var i = 0; i < 5; i++) {
        state = state.scorePoint(1);
      }
      state = state.scorePoint(1);
      expect(state.isFinished, isTrue);

      state = state.undoLastPoint();
      expect(state.isFinished, isFalse);
      expect(state.team1Points, 4);
      expect(state.team2Points, 5);
    });

    test('alternates teams and players every point', () {
      var state = TournamentMatchState(
        totalPoints: 20,
        servingTeamIndex: 0,
        servingPlayerIndex: 0,
      );

      state = state.scorePoint(0);
      expect(state.servingTeamIndex, 1);
      expect(state.servingPlayerIndex, 0);

      state = state.scorePoint(1);
      expect(state.servingTeamIndex, 0);
      expect(state.servingPlayerIndex, 1);

      state = state.scorePoint(0);
      expect(state.servingTeamIndex, 1);
      expect(state.servingPlayerIndex, 1);
    });
  });
}
