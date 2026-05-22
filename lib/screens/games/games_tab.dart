import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/game.dart';
import '../../models/match_mode.dart';
import 'active_game_screen.dart';
import 'create_game_screen.dart';

class GamesTab extends StatelessWidget {
  const GamesTab({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState.games,
      builder: (context, _) {
        final active = appState.games.activeGames;
        final history = appState.games.finishedGames;

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Игры',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _createGame(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Создать'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (active.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Text(
                        'Активные',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverList.separated(
                    itemCount: active.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _GameCard(
                        game: active[index],
                        onTap: () => _openGame(context, active[index].id),
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      'История',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                if (history.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('История игр пуста')),
                    ),
                  )
                else
                  SliverList.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _GameCard(
                        game: history[index],
                        onTap: () => _openGame(context, history[index].id),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateGameScreen(appState: appState),
      ),
    );
  }

  void _openGame(BuildContext context, String gameId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ActiveGameScreen(appState: appState, gameId: gameId),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onTap});

  final Game game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(
                  game.config.mode == MatchMode.standard
                      ? Icons.sports_score
                      : Icons.leaderboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(game.scoreSummary),
                    Text(
                      game.modeLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                game.isActive ? Icons.play_circle : Icons.check_circle,
                color: game.isActive ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
