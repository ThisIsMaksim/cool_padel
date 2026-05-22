import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final Widget? trailing;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.marginMobile,
        8,
        AppTheme.marginMobile,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          if (trailing != null)
            trailing!
          else if (trailingLabel != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailingLabel!.toUpperCase(),
                style: AppTheme.labelCaps(
                  Theme.of(context).colorScheme,
                  color: AppTheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
