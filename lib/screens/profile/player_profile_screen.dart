import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/tournament.dart';
import '../../widgets/player_avatar.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({
    super.key,
    required this.appState,
    required this.playerId,
  });

  final AppState appState;
  final String playerId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState.social,
      builder: (context, _) {
        final player = appState.social.playerById(playerId);
        if (player == null) {
          return const Scaffold(body: Center(child: Text('Игрок не найден')));
        }

        final profile = appState.social.profileForPlayer(player)!;
        final isFavorite = appState.social.isFavorite(playerId);
        final tournaments = profile.tournamentHistory
            .map(appState.social.tournamentById)
            .whereType<Tournament>()
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(player.name)),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: PlayerAvatar(player: player, radius: 40, showRating: true),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${player.rating} · ${player.level}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Center(child: Text('${player.club}, ${player.city}')),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => appState.social.toggleFavorite(playerId),
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                label: Text(isFavorite ? 'В избранном' : 'Добавить в избранное'),
              ),
              const SizedBox(height: 24),
              Text('Турниры', style: Theme.of(context).textTheme.titleMedium),
              ...tournaments.map(
                (t) => ListTile(title: Text(t.title), subtitle: Text(t.club)),
              ),
            ],
          ),
        );
      },
    );
  }
}
