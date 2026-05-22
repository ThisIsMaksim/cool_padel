import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../widgets/player_avatar.dart';
import '../profile/player_profile_screen.dart';

class RatingTab extends StatelessWidget {
  const RatingTab({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState.social,
      builder: (context, _) {
        final players = appState.social.ratingList;

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Text(
                    'Рейтинг',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              SliverList.separated(
                itemCount: players.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final player = players[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            PlayerAvatar(player: player, radius: 16),
                            const SizedBox(width: 12),
                            Expanded(child: Text(player.name)),
                          ],
                        ),
                        subtitle: Text('${player.level} · ${player.club}'),
                        trailing: Text(
                          '${player.rating}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PlayerProfileScreen(
                                appState: appState,
                                playerId: player.id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}
