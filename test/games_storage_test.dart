import 'package:cool_padel/models/game.dart';
import 'package:cool_padel/models/match_config.dart';
import 'package:cool_padel/models/match_mode.dart';
import 'package:cool_padel/models/standard_match_state.dart';
import 'package:cool_padel/models/tournament_match_state.dart';
import 'package:cool_padel/state/games_repository.dart';
import 'package:cool_padel/storage/game_serialization.dart';
import 'package:cool_padel/storage/games_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameSerialization', () {
    test('roundtrips standard game', () {
      final game = Game(
        id: '1',
        config: const MatchConfig(
          mode: MatchMode.standard,
          team1Name: 'Alpha',
          team2Name: 'Beta',
          setsToWin: 2,
          participantIds: ['p1', 'p2'],
        ),
        createdAt: DateTime(2026, 5, 20, 12),
        standardState: StandardMatchState(
          setsToWin: 2,
          completedSets: const [SetScore(team1Games: 6, team2Games: 4)],
          currentSet: const SetScore(team1Games: 3, team2Games: 2),
          team1Points: 2,
          team2Points: 1,
          servingTeamIndex: 1,
        ),
      );

      final restored = GameSerialization.gameFromJson(
        GameSerialization.gameToJson(game),
      );

      expect(restored.id, game.id);
      expect(restored.config.participantIds, ['p1', 'p2']);
      expect(restored.standardState?.servingTeamIndex, 1);
    });

    test('roundtrips tournament game', () {
      final game = Game(
        id: '2',
        config: const MatchConfig(
          mode: MatchMode.tournament,
          team1Name: 'A',
          team2Name: 'B',
          totalPoints: 50,
          minPointLead: 2,
        ),
        createdAt: DateTime(2026, 5, 20, 13),
        status: GameStatus.inProgress,
        tournamentState: const TournamentMatchState(
          totalPoints: 50,
          minPointLead: 2,
          team1Points: 12,
          team2Points: 8,
        ),
      );

      final jsonString = GameSerialization.gamesToJsonString([game]);
      final restored = GameSerialization.gamesFromJsonString(jsonString);

      expect(restored.length, 1);
      expect(restored.first.tournamentState?.minPointLead, 2);
    });
  });

  group('GamesRepository persistence', () {
    test('saves and loads games from storage', () async {
      final storage = InMemoryGamesStorage();
      final repo = GamesRepository(storage: storage);

      repo.createGame(
        const MatchConfig(
          mode: MatchMode.tournament,
          team1Name: 'One',
          team2Name: 'Two',
          totalPoints: 20,
        ),
      );

      await repo.flushPersistence();

      final reloadedRepo = GamesRepository(storage: storage);
      await reloadedRepo.load();

      expect(reloadedRepo.games.length, 1);
      expect(reloadedRepo.games.first.config.team1Name, 'One');
    });
  });
}
