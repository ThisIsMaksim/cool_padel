import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/game.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/section_header.dart';
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
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: AppHeader(
                  title: 'CoolPadel',
                  showLogo: true,
                  notificationCount: 2,
                  onProfileTap: onOpenProfile,
                  onNotificationsTap: () {},
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Турниры',
                  trailingLabel: 'Все',
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 190,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.88),
                    padEnds: false,
                    clipBehavior: Clip.none,
                    itemCount: carouselItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? AppTheme.marginMobile : 12,
                          right: index == carouselItems.length - 1
                              ? AppTheme.marginMobile
                              : 12,
                        ),
                        child: _CarouselCard(
                          appState: appState,
                          item: carouselItems[index],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Показатели'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.marginMobile,
                  ),
                  child: Row(
                    children: [
                      _QuickStat(
                        label: 'Серия побед',
                        value: '${appState.games.activeCount}',
                        glow: true,
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
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Рядом'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.marginMobile,
                    0,
                    AppTheme.marginMobile,
                    120,
                  ),
                  child: AppTheme.glassSurface(
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_offer,
                            color: AppTheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Premium-корт',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Скидка 20% · Padel Club Moscow',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppTheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
      return AppTheme.glassSurface(
        child: Center(
          child: Text(
            'Создайте игру или запишитесь на турнир',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final isGame = item.game != null;
    final title = isGame ? item.game!.title : item.tournament!.title;
    final subtitle = isGame
        ? item.game!.scoreSummary
        : '${item.tournament!.club} · ${item.tournament!.formatLabel}';

    return AppTheme.glassSurface(
      glow: isGame,
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
      child: SizedBox(
        height: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(
                (isGame ? 'Игра' : 'Турнир').toUpperCase(),
                style: AppTheme.labelCaps(
                  Theme.of(context).colorScheme,
                  color: isGame ? AppTheme.onPrimary : AppTheme.primary,
                ).copyWith(fontSize: 10),
              ),
              backgroundColor:
                  isGame ? AppTheme.primary : AppTheme.surfaceContainerHigh,
              side: BorderSide(
                color: AppTheme.primary.withValues(alpha: 0.3),
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    this.glow = false,
  });

  final String label;
  final String value;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: AppTheme.glassSurface(
        glow: glow,
        child: SizedBox(
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (glow)
                const Icon(Icons.bolt, color: AppTheme.primary, size: 28),
              const Spacer(),
              Text(
                value,
                style: AppTheme.dataMono(scheme, color: AppTheme.primary, size: 40),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: AppTheme.labelCaps(scheme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
