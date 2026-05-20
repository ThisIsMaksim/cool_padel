import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/tournament_match_state.dart';
import '../state/games_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/team_score_panel.dart';

class TournamentMatchScreen extends StatefulWidget {
  const TournamentMatchScreen({
    super.key,
    required this.game,
    required this.gamesRepository,
  });

  final Game game;
  final GamesRepository gamesRepository;

  @override
  State<TournamentMatchScreen> createState() => _TournamentMatchScreenState();
}

class _TournamentMatchScreenState extends State<TournamentMatchScreen> {
  late TournamentMatchState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.game.tournamentState ??
        TournamentMatchState(totalPoints: widget.game.config.totalPoints);
  }

  void _score(int teamIndex) {
    setState(() {
      _state = _state.scorePoint(teamIndex);
      widget.gamesRepository.updateTournamentState(widget.game.id, _state);
    });
  }

  void _undo() {
    setState(() {
      _state = _state.undoLastPoint();
      widget.gamesRepository.updateTournamentState(widget.game.id, _state);
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.game.config;
    final winnerName = _state.winnerIndex == 0
        ? config.team1Name
        : _state.winnerIndex == 1
            ? config.team2Name
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('${config.team1Name} vs ${config.team2Name}'),
        actions: [
          IconButton(
            onPressed: _undo,
            icon: const Icon(Icons.undo),
            tooltip: 'Отменить очко',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Лимит: ${config.totalPoints} очков',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _state.progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Сыграно: ${_state.playedPoints} / ${config.totalPoints}  '
                      '(осталось ${_state.remainingPoints})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (_state.isFinished && winnerName != null) ...[
              const SizedBox(height: 12),
              MatchFinishedBanner(winnerName: winnerName),
            ] else if (_state.isFinished) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Матч завершён — ничья ${_state.team1Points}:${_state.team2Points}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TeamScorePanel(
                    teamName: config.team1Name,
                    primaryScore: '${_state.team1Points}',
                    subtitle: '1 мяч = 1 очко',
                    color: AppTheme.team1Color,
                    enabled: !_state.isFinished,
                    onScore: () => _score(0),
                  ),
                  const SizedBox(width: 12),
                  TeamScorePanel(
                    teamName: config.team2Name,
                    primaryScore: '${_state.team2Points}',
                    subtitle: '1 мяч = 1 очко',
                    color: AppTheme.team2Color,
                    enabled: !_state.isFinished,
                    onScore: () => _score(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Матч заканчивается, когда сумма очков обеих команд '
              'достигает ${config.totalPoints}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
