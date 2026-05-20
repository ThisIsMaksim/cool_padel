import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../../models/match_mode.dart';
import '../../state/games_repository.dart';
import '../match_setup_screen.dart';
import '../standard_match_screen.dart';
import '../tournament_match_screen.dart';

class GamesTab extends StatelessWidget {
  const GamesTab({super.key, required this.gamesRepository});

  final GamesRepository gamesRepository;

  void _openGame(BuildContext context, Game game) {
    final screen = game.config.mode == MatchMode.standard
        ? StandardMatchScreen(
            game: game,
            gamesRepository: gamesRepository,
          )
        : TournamentMatchScreen(
            game: game,
            gamesRepository: gamesRepository,
          );

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _createGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchSetupScreen(gamesRepository: gamesRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final games = gamesRepository.games;

    return Scaffold(
      appBar: AppBar(title: const Text('Игры')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createGame(context),
        icon: const Icon(Icons.add),
        label: const Text('Создать игру'),
      ),
      body: games.isEmpty
          ? _EmptyGames(onCreate: () => _createGame(context))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: games.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final game = games[index];
                return _GameListTile(
                  game: game,
                  onTap: () => _openGame(context, game),
                  onDelete: () => gamesRepository.removeGame(game.id),
                );
              },
            ),
    );
  }
}

class _EmptyGames extends StatelessWidget {
  const _EmptyGames({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_tennis_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Нет игр',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте первую игру и начните вести счёт',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Создать игру'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameListTile extends StatelessWidget {
  const _GameListTile({
    required this.game,
    required this.onTap,
    required this.onDelete,
  });

  final Game game;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isFinished = game.status == GameStatus.finished;

    return Dismissible(
      key: ValueKey(game.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
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
                      const SizedBox(height: 4),
                      Text(game.scoreSummary),
                      const SizedBox(height: 4),
                      Text(
                        game.modeLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Chip(
                      label: Text(isFinished ? 'Завершена' : 'Идёт'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: isFinished
                          ? Colors.grey.shade200
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
