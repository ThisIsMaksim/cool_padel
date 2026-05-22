import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/game.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../games/active_game_screen.dart';
import '../tournaments/tournament_detail_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.appState,
    required this.onOpenProfile,
  });

  final AppState appState;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState.games, appState.social]),
      builder: (context, _) {
        final upcomingGames = appState.games.activeGames.take(5).toList();
        final upcomingTournaments =
            appState.social.activeTournaments.take(5).toList();
        final carouselItems = _carouselItems(upcomingGames, upcomingTournaments);

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: AppHeader(
                  title: 'CoolPadel',
                  notificationCount: 2,
                  onProfileTap: onOpenProfile,
                  onNotificationsTap: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 190,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.88),
                    itemCount: carouselItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 12, right: 4, bottom: 8),
                        child: _CarouselCard(
                          appState: appState,
                          item: carouselItems[index],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient.gradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Premium-корт',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Скидка 20% на бронирование в Padel Club Moscow',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.local_offer,
                            color: AppTheme.accentGold, size: 40),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _QuickStat(
                        label: 'Активные игры',
                        value: '${appState.games.activeCount}',
                      ),
                      const SizedBox(width: 12),
                      _QuickStat(
                        label: 'Турниры',
                        value: '${appState.social.activeTournaments.length}',
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  List<_CarouselItem> _carouselItems(
    List<Game> games,
    List<Tournament> tournaments,
  ) {
    final items = <_CarouselItem>[];
    for (final g in games) {
      items.add(_CarouselItem.game(g));
    }
    for (final t in tournaments) {
      items.add(_CarouselItem.tournament(t));
    }
    if (items.isEmpty) {
      items.add(const _CarouselItem.placeholder());
    }
    return items;
  }
}

class _CarouselItem {
  const _CarouselItem.game(this.game)
      : tournament = null,
        isPlaceholder = false;

  const _CarouselItem.tournament(this.tournament)
      : game = null,
        isPlaceholder = false;

  const _CarouselItem.placeholder()
      : game = null,
        tournament = null,
        isPlaceholder = true;

  final Game? game;
  final Tournament? tournament;
  final bool isPlaceholder;
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.appState, required this.item});

  final AppState appState;
  final _CarouselItem item;

  @override
  Widget build(BuildContext context) {
    if (item.isPlaceholder) {
      return Card(
        child: Center(
          child: Text(
            'Создайте игру или запишитесь на турнир',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final isGame = item.game != null;
    final title = isGame ? item.game!.title : item.tournament!.title;
    final subtitle = isGame
        ? item.game!.scoreSummary
        : '${item.tournament!.club} · ${item.tournament!.formatLabel}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isGame) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ActiveGameScreen(
                  appState: appState,
                  gameId: item.game!.id,
                ),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TournamentDetailScreen(
                  appState: appState,
                  tournamentId: item.tournament!.id,
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.brandPrimary.withValues(alpha: 0.9),
                AppTheme.brandLight.withValues(alpha: 0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text(isGame ? 'Игра' : 'Турнир'),
                backgroundColor: Colors.white24,
                labelStyle: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
