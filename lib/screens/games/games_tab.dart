import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/game.dart';
import '../../theme/app_theme.dart';
import 'active_game_screen.dart';

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

        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.marginMobile,
                    12,
                    AppTheme.marginMobile,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Игры',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      if (active.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'LIVE',
                            style: AppTheme.labelCaps(
                              Theme.of(context).colorScheme,
                              color: AppTheme.secondary,
                            ).copyWith(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (active.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.marginMobile),
                    child: _GameCard(
                      game: active.first,
                      glow: true,
                      onTap: () => _openGame(context, active.first.id),
                    ),
                  ),
                ),
                if (active.length > 1)
                  SliverList.separated(
                    itemCount: active.length - 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.marginMobile,
                      ),
                      child: _GameCard(
                        game: active[index + 1],
                        onTap: () => _openGame(context, active[index + 1].id),
                      ),
                    ),
                  ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.marginMobile,
                    16,
                    AppTheme.marginMobile,
                    8,
                  ),
                  child: Text(
                    'НЕДАВНИЕ МАТЧИ',
                    style: AppTheme.labelCaps(
                      Theme.of(context).colorScheme,
                    ).copyWith(
                      color: AppTheme.secondary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              if (history.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'История игр пуста',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.marginMobile,
                    ),
                    child: _GameCard(
                      game: history[index],
                      onTap: () => _openGame(context, history[index].id),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
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
  const _GameCard({
    required this.game,
    required this.onTap,
    this.glow = false,
  });

  final Game game;
  final VoidCallback onTap;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppTheme.glassSurface(
      glow: glow,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (game.isActive)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (!game.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ЗАВЕРШЕНА',
                          style: AppTheme.labelCaps(
                            scheme,
                            color: AppTheme.primary,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                    Text(
                      game.modeLabel.toUpperCase(),
                      style: AppTheme.labelCaps(scheme)
                          .copyWith(fontSize: 10, color: AppTheme.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  game.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  game.scoreSummary,
                  style: AppTheme.dataMono(
                    scheme,
                    color: AppTheme.onSurface,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            game.isActive ? Icons.play_circle_outline : Icons.chevron_right,
            color: game.isActive
                ? AppTheme.primary
                : AppTheme.secondary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
