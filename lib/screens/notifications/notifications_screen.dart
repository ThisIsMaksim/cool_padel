import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../tournaments/tournament_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState.notifications,
      builder: (context, _) {
        final items = appState.notifications.items;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Уведомления'),
            actions: [
              if (items.any((n) => !n.read))
                TextButton(
                  onPressed: () => appState.notifications.markAllRead(),
                  child: const Text('Прочитать все'),
                ),
            ],
          ),
          body: items.isEmpty
              ? const Center(child: Text('Пока нет уведомлений'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = items[index];
                    return ListTile(
                      tileColor: n.read
                          ? null
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.06),
                      title: Text(n.title),
                      subtitle: Text(n.body),
                      trailing: Text(
                        _formatTime(n.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () async {
                        await appState.notifications.markRead(n.id);
                        if (!context.mounted) return;
                        _openLink(context, n.linkPath);
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  void _openLink(BuildContext context, String? linkPath) {
    if (linkPath == null) return;
    if (linkPath.startsWith('/t/')) {
      final id = linkPath.split('/').last;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TournamentDetailScreen(
            appState: appState,
            tournamentId: id,
          ),
        ),
      );
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}';
  }
}
