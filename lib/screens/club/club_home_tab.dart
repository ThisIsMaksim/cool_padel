import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/section_header.dart';
import '../notifications/notifications_screen.dart';
import '../tournaments/create_tournament_screen.dart';
import '../tournaments/tournament_detail_screen.dart';

class ClubHomeTab extends StatelessWidget {
  const ClubHomeTab({
    super.key,
    required this.appState,
    required this.onOpenProfile,
  });

  final AppState appState;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        appState.auth,
        appState.social,
        appState.notifications,
      ]),
      builder: (context, _) {
        final user = appState.auth.currentUser!;
        final myTournaments = appState.social.myTournaments;

        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: AppHeader(
                  title: user.club.isNotEmpty ? user.club : user.name,
                  showLogo: true,
                  notificationCount: appState.notifications.unreadCount,
                  onProfileTap: onOpenProfile,
                  onNotificationsTap: () => _openNotifications(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.marginMobile),
                  child: AppTheme.glassSurface(
                    glow: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Кабинет клуба',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Создавайте турниры, следите за регистрациями '
                          'и делитесь QR-кодом с игроками.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CreateTournamentScreen(
                                appState: appState,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Новый турнир'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Мои турниры'),
              ),
              if (myTournaments.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.marginMobile),
                    child: AppTheme.glassSurface(
                      child: const Text('Вы ещё не создавали турниры'),
                    ),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: myTournaments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = myTournaments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.marginMobile,
                      ),
                      child: AppTheme.glassSurface(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TournamentDetailScreen(
                              appState: appState,
                              tournamentId: t.id,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${t.participantIds.length}/${t.maxParticipants} участников · '
                              '${t.isFull ? 'Мест нет' : '${t.freeSlots} мест'}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(appState: appState),
      ),
    );
  }
}
