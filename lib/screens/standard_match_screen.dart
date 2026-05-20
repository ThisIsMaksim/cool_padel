import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/standard_match_state.dart';
import '../state/games_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/team_score_panel.dart';

class StandardMatchScreen extends StatefulWidget {
  const StandardMatchScreen({
    super.key,
    required this.game,
    required this.gamesRepository,
  });

  final Game game;
  final GamesRepository gamesRepository;

  @override
  State<StandardMatchScreen> createState() => _StandardMatchScreenState();
}

class _StandardMatchScreenState extends State<StandardMatchScreen> {
  late StandardMatchState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.game.standardState ??
        StandardMatchState(setsToWin: widget.game.config.setsToWin);
  }

  void _score(int teamIndex) {
    setState(() {
      _state = _state.scorePoint(teamIndex);
      widget.gamesRepository.updateStandardState(widget.game.id, _state);
    });
  }

  void _undo() {
    setState(() {
      _state = _state.undoLastPoint();
      widget.gamesRepository.updateStandardState(widget.game.id, _state);
    });
  }

  String _setsDisplay() {
    final completed = _state.completedSets
        .map((s) => '${s.team1Games}:${s.team2Games}')
        .join('  ');
    final current =
        '${_state.currentSet.team1Games}:${_state.currentSet.team2Games}';
    if (completed.isEmpty) return current;
    return '$completed  ($current)';
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.game.config;
    final winnerName = _state.winnerIndex == 0
        ? config.team1Name
        : config.team2Name;

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
            if (_state.isTiebreak)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Тай-брейк',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Сеты',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_state.team1Sets} : ${_state.team2Sets}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Геймы: ${_setsDisplay()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (_state.isFinished) ...[
              const SizedBox(height: 12),
              MatchFinishedBanner(winnerName: winnerName),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TeamScorePanel(
                    teamName: config.team1Name,
                    primaryScore: _state.formatPoint(_state.team1Points, 0),
                    secondaryScore:
                        '${_state.currentSet.team1Games} гейм${_state.isTiebreak ? ' (TB)' : ''}',
                    color: AppTheme.team1Color,
                    enabled: !_state.isFinished,
                    onScore: () => _score(0),
                  ),
                  const SizedBox(width: 12),
                  TeamScorePanel(
                    teamName: config.team2Name,
                    primaryScore: _state.formatPoint(_state.team2Points, 1),
                    secondaryScore:
                        '${_state.currentSet.team2Games} гейм${_state.isTiebreak ? ' (TB)' : ''}',
                    color: AppTheme.team2Color,
                    enabled: !_state.isFinished,
                    onScore: () => _score(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите на панель команды, чтобы засчитать выигранное очко',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
