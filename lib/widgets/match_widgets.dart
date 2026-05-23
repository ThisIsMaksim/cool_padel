import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MatchFinishedBanner extends StatelessWidget {
  const MatchFinishedBanner({super.key, required this.winnerName});

  final String winnerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: AppTheme.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Победитель: $winnerName',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServingBanner extends StatelessWidget {
  const ServingBanner({
    super.key,
    required this.serverName,
    required this.receiverName,
    this.serverSide,
    this.receiverSide,
  });

  final String serverName;
  final String receiverName;
  final String? serverSide;
  final String? receiverSide;

  @override
  Widget build(BuildContext context) {
    final serverLabel = serverSide != null ? '$serverName ($serverSide)' : serverName;
    final receiverLabel =
        receiverSide != null ? '$receiverName ($receiverSide)' : receiverName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.sports_tennis, color: AppTheme.brandPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Подача: $serverLabel → $receiverLabel',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
