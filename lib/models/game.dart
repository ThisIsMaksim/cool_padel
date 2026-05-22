import 'match_config.dart';
import 'match_mode.dart';
import 'standard_match_state.dart';
import 'tournament_match_state.dart';

enum GameStatus { inProgress, finished }

class Game {
  Game({
    required this.id,
    required this.config,
    required this.createdAt,
    this.status = GameStatus.inProgress,
    this.standardState,
    this.tournamentState,
  });

  final String id;
  final MatchConfig config;
  final DateTime createdAt;
  GameStatus status;
  StandardMatchState? standardState;
  TournamentMatchState? tournamentState;

  String get title => '${config.team1Name} vs ${config.team2Name}';

  String get modeLabel => config.mode.title;

  bool get isActive => status == GameStatus.inProgress;

  String get scoreSummary {
    if (config.mode == MatchMode.standard && standardState != null) {
      final state = standardState!;
      if (state.isFinished) {
        final winner = state.winnerIndex == 0
            ? config.team1Name
            : config.team2Name;
        return 'Завершена · ${state.team1Sets}:${state.team2Sets} · $winner';
      }
      return 'Сеты ${state.team1Sets}:${state.team2Sets} · '
          'Геймы ${state.currentSet.team1Games}:${state.currentSet.team2Games}';
    }

    if (config.mode == MatchMode.tournament && tournamentState != null) {
      final state = tournamentState!;
      if (state.isFinished) {
        if (state.winnerIndex == null) {
          return 'Ничья ${state.team1Points}:${state.team2Points}';
        }
        final winner = state.winnerIndex == 0
            ? config.team1Name
            : config.team2Name;
        return 'Завершена · ${state.team1Points}:${state.team2Points} · $winner';
      }
      return '${state.team1Points}:${state.team2Points} · '
          '${state.playedPoints}/${state.totalPoints}';
    }

    return 'В процессе';
  }

  Game copyWith({
    GameStatus? status,
    StandardMatchState? standardState,
    TournamentMatchState? tournamentState,
    bool clearStandardState = false,
    bool clearTournamentState = false,
  }) {
    return Game(
      id: id,
      config: config,
      createdAt: createdAt,
      status: status ?? this.status,
      standardState:
          clearStandardState ? null : (standardState ?? this.standardState),
      tournamentState: clearTournamentState
          ? null
          : (tournamentState ?? this.tournamentState),
    );
  }
}
