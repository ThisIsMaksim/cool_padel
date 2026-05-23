import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GlassSelectTile extends StatelessWidget {
  const GlassSelectTile({
    super.key,
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.centerText = true,
    this.glow = false,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final bool centerText;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final showGlow = glow || selected;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: padding,
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.12)
                : AppTheme.glassFill,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.glassBorder,
              width: 1.5,
            ),
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: centerText
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: centerText ? TextAlign.center : TextAlign.start,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? AppTheme.primary : AppTheme.onSurface,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: centerText ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
