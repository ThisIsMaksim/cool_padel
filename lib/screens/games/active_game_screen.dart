import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_state.dart';
import '../../models/deuce_rule.dart';
import '../../models/game.dart';
import '../../models/match_config.dart';
import '../../models/match_mode.dart';
import '../../models/team_member.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_select_tile.dart';
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
    final scheme = Theme.of(context).colorScheme;
    return AppTheme.glassSurface(
      padding: const EdgeInsets.all(AppTheme.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'СОСТАВ',
            style: AppTheme.labelCaps(
              scheme,
              color: AppTheme.secondary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          _teamLine('К1', config.team1Members, AppTheme.team1Color),
          const SizedBox(height: 8),
          _teamLine('К2', config.team2Members, AppTheme.team2Color),
        ],
      ),
    );
  }

  Widget _teamLine(String label, List<TeamMember> members, Color color) {
    final scheme = Theme.of(context).colorScheme;
    final text = members
        .map((m) => m.side != null ? '${m.shortName} (${m.side!.label})' : m.shortName)
        .join(' · ');
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Text(
            label,
            style: AppTheme.labelCaps(scheme, color: color).copyWith(fontSize: 10),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
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
        padding: const EdgeInsets.all(AppTheme.marginMobile),
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
              AppTheme.glassSurface(
                glow: true,
                padding: const EdgeInsets.all(12),
                child: Text(
                  'ТАЙ-БРЕЙК',
                  textAlign: TextAlign.center,
                  style: AppTheme.labelCaps(
                    Theme.of(context).colorScheme,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            AppTheme.glassSurface(
              child: Column(
                children: [
                  Text(
                    '${state.team1Sets}:${state.team2Sets}',
                    style: AppTheme.dataMono(
                      Theme.of(context).colorScheme,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'СЕТЫ',
                    style: AppTheme.labelCaps(Theme.of(context).colorScheme),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Геймы ${state.currentSet.team1Games}:${state.currentSet.team2Games}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Deuce: ${state.deuceRule.title}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (state.isFinished)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    MatchFinishedBanner(
                      winnerName: state.winnerIndex == 0
                          ? config.team1Name
                          : config.team2Name,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _shareResult(game),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Поделиться результатом'),
                    ),
                  ],
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
        padding: const EdgeInsets.all(AppTheme.marginMobile),
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
            AppTheme.glassSurface(
              child: Column(
                children: [
                  Text(
                    'Лимит ${state.totalPoints} · разница ${state.minPointLead}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      color: AppTheme.primary,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.playedPoints}/${state.totalPoints} очков',
                    style: AppTheme.dataMono(
                      Theme.of(context).colorScheme,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (state.isFinished && winnerName != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    MatchFinishedBanner(winnerName: winnerName),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _shareResult(game),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Поделиться результатом'),
                    ),
                  ],
                ),
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
    final wasFinished = game.standardState!.isFinished;
    final newState = game.standardState!.scorePoint(teamIndex);
    widget.appState.games.updateStandardState(game.id, newState);
    if (newState.isFinished && !wasFinished) {
      widget.appState.afterGameFinished();
    }
  }

  void _scoreTournament(int teamIndex) {
    final game = _game!;
    final wasFinished = game.tournamentState!.isFinished;
    final newState = game.tournamentState!.scorePoint(teamIndex);
    widget.appState.games.updateTournamentState(game.id, newState);
    if (newState.isFinished && !wasFinished) {
      widget.appState.afterGameFinished();
    }
  }

  Future<void> _shareResult(Game game) async {
    await Share.share(
      '${game.title}\n${game.scoreSummary}\n— CoolPadel',
      subject: game.title,
    );
  }

  Future<void> _pickDeuceRule(Game game) async {
    final scheme = Theme.of(context).colorScheme;
    final selected = await showModalBottomSheet<DeuceRule>(
      context: context,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.marginMobile,
          12,
          AppTheme.marginMobile,
          24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              'ПРАВИЛО DEUCE',
              style: AppTheme.labelCaps(
                scheme,
                color: AppTheme.secondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            ...DeuceRule.values.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassSelectTile(
                  label: rule.title,
                  subtitle: rule.subtitle,
                  selected: game.standardState!.deuceRule == rule,
                  onTap: () => Navigator.pop(ctx, rule),
                  centerText: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      widget.appState.games.updateDeuceRule(game.id, selected);
    }
  }
}
