import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_screen.dart';
import '../tournaments/tournament_detail_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        appState.auth,
        appState.social,
        appState.games,
      ]),
      builder: (context, _) {
        final user = appState.auth.currentUser;
        if (user == null) {
          return const Center(child: Text('Не авторизован'));
        }

        final stats = appState.games.stats;

        final tournaments = user.tournamentHistory
            .map(appState.social.tournamentById)
            .whereType<Tournament>()
            .toList();

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    child: Text(
                      user.initials,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(user.email),
                        Text(
                          user.isClub
                              ? 'Клуб · ${user.club}'
                              : '${user.city} · ${user.club}',
                        ),
                        if (user.isClub)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Chip(
                              label: Text(user.accountType.title),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _ProfileStat(label: 'Рейтинг', value: '${user.rating}'),
                  const SizedBox(width: 12),
                  _ProfileStat(label: 'Уровень', value: user.level),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'СТАТИСТИКА МАТЧЕЙ',
                style: AppTheme.labelCaps(
                  Theme.of(context).colorScheme,
                  color: AppTheme.secondary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ProfileStat(label: 'Побед', value: '${stats.wins}'),
                  const SizedBox(width: 12),
                  _ProfileStat(label: 'Поражений', value: '${stats.losses}'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ProfileStat(label: 'Win rate', value: '${stats.winRate}%'),
                  const SizedBox(width: 12),
                  _ProfileStat(
                    label: 'Серия',
                    value: stats.currentStreak > 0
                        ? '+${stats.currentStreak}'
                        : '${stats.currentStreak}',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'История турниров',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (tournaments.isEmpty)
                const Text('Пока нет участий')
              else
                ...tournaments.map(
                  (t) => ListTile(
                    title: Text(t.title),
                    subtitle: Text(t.club),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TournamentDetailScreen(
                            appState: appState,
                            tournamentId: t.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  await appState.auth.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => LoginScreen(appState: appState),
                    ),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Выйти'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

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
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
