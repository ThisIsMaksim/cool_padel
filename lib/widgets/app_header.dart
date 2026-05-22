import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onProfileTap,
    this.onNotificationsTap,
    this.notificationCount = 0,
  });

  final String title;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brandDark,
                  ),
            ),
          ),
          IconButton(
            onPressed: onNotificationsTap,
            icon: Badge(
              isLabelVisible: notificationCount > 0,
              label: Text('$notificationCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            onPressed: onProfileTap,
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.accent,
              child: Icon(Icons.person, size: 20, color: AppTheme.brandDark),
            ),
          ),
        ],
      ),
    );
  }
}
