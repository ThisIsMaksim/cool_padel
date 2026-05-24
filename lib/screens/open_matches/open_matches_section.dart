import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/open_match.dart';
import '../../theme/app_theme.dart';
import 'create_open_match_screen.dart';

class OpenMatchesSection extends StatelessWidget {
  const OpenMatchesSection({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final matches = appState.openMatches.openMatches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'OPEN MATCH',
                style: AppTheme.labelCaps(
                  Theme.of(context).colorScheme,
                  color: AppTheme.secondary.withValues(alpha: 0.6),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      CreateOpenMatchScreen(appState: appState),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Создать'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (matches.isEmpty)
          AppTheme.glassSurface(
            child: Text(
              'Пока никто не ищет партнёров. Создайте open match!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          ...matches.take(5).map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _OpenMatchTile(appState: appState, match: m),
                ),
              ),
      ],
    );
  }
}

class _OpenMatchTile extends StatelessWidget {
  const _OpenMatchTile({required this.appState, required this.match});

  final AppState appState;
  final OpenMatch match;

  @override
  Widget build(BuildContext context) {
    final userId = appState.auth.currentUser?.id;
    final joined = userId != null && match.participantIds.contains(userId);

    return AppTheme.glassSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${match.club} · ${match.formatLabel}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            '${match.level} · ${_formatDate(match.dateTime)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (match.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(match.note),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Свободно: ${match.freeSlots}'),
              const Spacer(),
              if (joined)
                const Chip(label: Text('Вы в игре'))
              else if (match.isOpen)
                FilledButton(
                  onPressed: () async {
                    final error = await appState.openMatches.join(match.id);
                    if (context.mounted && error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  },
                  child: const Text('Присоединиться'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
