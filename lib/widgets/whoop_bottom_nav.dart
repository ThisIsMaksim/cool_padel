import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WhoopBottomNav extends StatelessWidget {
  const WhoopBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onFabPressed,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onFabPressed;

  static const _destinations = [
    (Icons.home_outlined, Icons.home, 'Главная'),
    (Icons.emoji_events_outlined, Icons.emoji_events, 'Турниры'),
    (Icons.sports_tennis_outlined, Icons.sports_tennis, 'Игры'),
    (Icons.leaderboard_outlined, Icons.leaderboard, 'Рейтинг'),
    (Icons.person_outline, Icons.person, 'Профиль'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.marginMobile,
        0,
        AppTheme.marginMobile,
        24,
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.glassBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_destinations.length, (index) {
                      final d = _destinations[index];
                      final selected = index == selectedIndex;
                      return Expanded(
                        child: InkWell(
                          onTap: () => onSelected(index),
                          borderRadius: BorderRadius.circular(999),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                selected ? d.$2 : d.$1,
                                size: 22,
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.onSurface.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                d.$3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.labelCaps(
                                  Theme.of(context).colorScheme,
                                  color: selected
                                      ? AppTheme.primary
                                      : AppTheme.onSurface
                                          .withValues(alpha: 0.4),
                                ).copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Material(
                color: AppTheme.surfaceContainerLow.withValues(alpha: 0.8),
                child: InkWell(
                  onTap: onFabPressed,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppTheme.onSurface,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
