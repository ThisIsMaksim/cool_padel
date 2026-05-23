import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/deuce_rule.dart';
import '../../models/game.dart';
import '../../models/match_config.dart';
import '../../models/match_mode.dart';
import '../../models/team_member.dart';
import '../../theme/app_theme.dart';
import '../../widgets/match_widgets.dart';
import '../../widgets/team_score_panel.dart';

class ActiveGameScreen extends StatefulWidget {
  const ActiveGameScreen({
    super.key,
    required this.appState,
    required this.gameId,
  });

  final AppState appState;
  final String gameId;

  @override
  State<ActiveGameScreen> createState() => _ActiveGameScreenState();
}

class _ActiveGameScreenState extends State<ActiveGameScreen> {
  Game? get _game => widget.appState.games.gameById(widget.gameId);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState.games,
      builder: (context, _) {
        final game = _game;
        if (game == null) {
          return const Scaffold(body: Center(child: Text('Игра не найдена')));
        }

        return game.config.mode == MatchMode.standard
            ? _buildStandard(context, game)
            : _buildTournament(context, game);
      },
    );
  }

  ({String server, String receiver, String? serverSide, String? receiverSide})
      _serveLabels(MatchConfig config, int teamIndex, int playerIndex) {
    final server = config.serverMember(teamIndex, playerIndex);
    final receiver = config.receiverMember(teamIndex, playerIndex);
    return (
      server: server?.shortName ?? config.membersForTeam(teamIndex).first.shortName,
      receiver: receiver?.shortName ??
          config.membersForTeam(teamIndex == 0 ? 1 : 0).first.shortName,
      serverSide: server?.side?.label,
      receiverSide: receiver?.side?.label,
    );
  }

  Widget _teamRoster(MatchConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Состав', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _teamLine('К1', config.team1Members),
            const SizedBox(height: 4),
            _teamLine('К2', config.team2Members),
          ],
        ),
      ),
    );
  }

  Widget _teamLine(String label, List<TeamMember> members) {
    final text = members
        .map((m) => m.side != null ? '${m.shortName} (${m.side!.label})' : m.shortName)
        .join(' · ');
    return Text('$label: $text');
  }

  Widget _buildStandard(BuildContext context, Game game) {
    final state = game.standardState!;
    final config = game.config;
    final serve = _serveLabels(
      config,
      state.servingTeamIndex,
      state.servingPlayerIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(game.title),
        actions: [
          if (state.isDeuceSituation)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Правило deuce',
              onPressed: () => _pickDeuceRule(game),
            ),
          IconButton(
            onPressed: state.canUndo
                ? () {
                    widget.appState.games.updateStandardState(
                      game.id,
                      state.undoLastPoint(),
                    );
                  }
                : null,
            icon: const Icon(Icons.undo),
            tooltip: 'Отменить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ServingBanner(
              serverName: serve.server,
              receiverName: serve.receiver,
              serverSide: serve.serverSide,
              receiverSide: serve.receiverSide,
            ),
            const SizedBox(height: 12),
            _teamRoster(config),
            const SizedBox(height: 12),
            if (state.isTiebreak)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Тай-брейк',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Сеты ${state.team1Sets}:${state.team2Sets}'),
                    Text(
                      'Геймы ${state.currentSet.team1Games}:${state.currentSet.team2Games}',
                    ),
                    Text(
                      'Deuce: ${state.deuceRule.title}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (state.isFinished)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: MatchFinishedBanner(
                  winnerName: state.winnerIndex == 0
                      ? config.team1Name
                      : config.team2Name,
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  TeamScorePanel(
                    teamName: config.team1Name,
                    primaryScore: state.formatPoint(state.team1Points, 0),
                    secondaryScore: '${state.currentSet.team1Games} гейм',
                    color: AppTheme.team1Color,
                    enabled: !state.isFinished,
                    onScore: () => _scoreStandard(0),
                  ),
                  const SizedBox(width: 12),
                  TeamScorePanel(
                    teamName: config.team2Name,
                    primaryScore: state.formatPoint(state.team2Points, 1),
                    secondaryScore: '${state.currentSet.team2Games} гейм',
                    color: AppTheme.team2Color,
                    enabled: !state.isFinished,
                    onScore: () => _scoreStandard(1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournament(BuildContext context, Game game) {
    final state = game.tournamentState!;
    final config = game.config;
    final serve = _serveLabels(
      config,
      state.servingTeamIndex,
      state.servingPlayerIndex,
    );

    final winnerName = state.winnerIndex == 0
        ? config.team1Name
        : state.winnerIndex == 1
            ? config.team2Name
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(game.title),
        actions: [
          IconButton(
            onPressed: state.canUndo
                ? () {
                    widget.appState.games.updateTournamentState(
                      game.id,
                      state.undoLastPoint(),
                    );
                  }
                : null,
            icon: const Icon(Icons.undo),
            tooltip: 'Отменить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ServingBanner(
              serverName: serve.server,
              receiverName: serve.receiver,
              serverSide: serve.serverSide,
              receiverSide: serve.receiverSide,
            ),
            const SizedBox(height: 12),
            _teamRoster(config),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Лимит ${state.totalPoints} · разница ${state.minPointLead}'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: state.progress),
                    Text(
                      '${state.playedPoints}/${state.totalPoints} очков',
                    ),
                  ],
                ),
              ),
            ),
            if (state.isFinished && winnerName != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: MatchFinishedBanner(winnerName: winnerName),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  TeamScorePanel(
                    teamName: config.team1Name,
                    primaryScore: '${state.team1Points}',
                    subtitle: '1 мяч = 1 балл',
                    color: AppTheme.team1Color,
                    enabled: !state.isFinished,
                    onScore: () => _scoreTournament(0),
                  ),
                  const SizedBox(width: 12),
                  TeamScorePanel(
                    teamName: config.team2Name,
                    primaryScore: '${state.team2Points}',
                    subtitle: '1 мяч = 1 балл',
                    color: AppTheme.team2Color,
                    enabled: !state.isFinished,
                    onScore: () => _scoreTournament(1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scoreStandard(int teamIndex) {
    final game = _game!;
    final newState = game.standardState!.scorePoint(teamIndex);
    widget.appState.games.updateStandardState(game.id, newState);
  }

  void _scoreTournament(int teamIndex) {
    final game = _game!;
    final newState = game.tournamentState!.scorePoint(teamIndex);
    widget.appState.games.updateTournamentState(game.id, newState);
  }

  Future<void> _pickDeuceRule(Game game) async {
    final selected = await showModalBottomSheet<DeuceRule>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: DeuceRule.values
            .map(
              (rule) => ListTile(
                title: Text(rule.title),
                subtitle: Text(rule.subtitle),
                onTap: () => Navigator.pop(ctx, rule),
              ),
            )
            .toList(),
      ),
    );

    if (selected != null) {
      widget.appState.games.updateDeuceRule(game.id, selected);
    }
  }
}
