import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onProfileTap,
    this.onNotificationsTap,
    this.notificationCount = 0,
    this.showLogo = false,
  });

  final String title;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;
  final int notificationCount;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.background.withValues(alpha: 0.8),
            border: const Border(
              bottom: BorderSide(color: AppTheme.glassBorder),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppTheme.marginMobile,
            8,
            8,
            8,
          ),
          child: Row(
            children: [
              if (onProfileTap != null) ...[
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                      color: AppTheme.surfaceContainerHigh,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 22,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (showLogo)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.sports_tennis,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
              IconButton(
                onPressed: onNotificationsTap,
                icon: Badge(
                  isLabelVisible: notificationCount > 0,
                  backgroundColor: AppTheme.primary,
                  label: Text(
                    '$notificationCount',
                    style: const TextStyle(
                      color: AppTheme.onPrimary,
                      fontSize: 10,
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
