import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TeamScorePanel extends StatelessWidget {
  const TeamScorePanel({
    super.key,
    required this.teamName,
    required this.primaryScore,
    this.secondaryScore,
    required this.color,
    required this.onScore,
    this.subtitle,
    this.enabled = true,
  });

  final String teamName;
  final String primaryScore;
  final String? secondaryScore;
  final Color color;
  final VoidCallback onScore;
  final String? subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onScore : null,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: color.withValues(alpha: enabled ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    teamName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    primaryScore,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                          height: 1,
                        ),
                  ),
                  if (secondaryScore != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      secondaryScore!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: color.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (enabled)
                    Icon(Icons.add_circle_outline, color: color, size: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MatchFinishedBanner extends StatelessWidget {
  const MatchFinishedBanner({super.key, required this.winnerName});

  final String winnerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: AppTheme.team1Color),
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
