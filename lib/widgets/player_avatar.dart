import 'package:flutter/material.dart';

import '../models/player.dart';
import '../theme/app_theme.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.player,
    this.radius = 22,
    this.showRating = false,
  });

  final Player player;
  final double radius;
  final bool showRating;

  @override
  Widget build(BuildContext context) {
    final color = Color(player.avatarColor ?? AppTheme.brandPrimary.toARGB32());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: color.withValues(alpha: 0.18),
          child: Text(
            player.initials,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.72,
            ),
          ),
        ),
        if (showRating) ...[
          const SizedBox(height: 4),
          Text(
            '${player.rating}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}
