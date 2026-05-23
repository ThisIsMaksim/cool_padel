import 'package:flutter/material.dart';

import '../../models/game_format.dart';
import '../../models/match_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_select_tile.dart';

class ServeSetup {
  const ServeSetup({
    required this.servingTeamIndex,
    required this.servingPlayerIndex,
  });

  final int servingTeamIndex;
  final int servingPlayerIndex;
}

Future<ServeSetup?> showServeSelectionDialog(
  BuildContext context,
  MatchConfig config,
) {
  return showModalBottomSheet<ServeSetup>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
    ),
    builder: (ctx) => _ServeSelectionSheet(config: config),
  );
}

class _ServeSelectionSheet extends StatefulWidget {
  const _ServeSelectionSheet({required this.config});

  final MatchConfig config;

  @override
  State<_ServeSelectionSheet> createState() => _ServeSelectionSheetState();
}

class _ServeSelectionSheetState extends State<_ServeSelectionSheet> {
  int? _servingTeamIndex;
  int? _servingPlayerIndex;

  bool get _isDoubles => widget.config.gameFormat == GameFormat.doubles2x2;

  void _confirm() {
    if (_servingTeamIndex == null) return;
    Navigator.pop(
      context,
      ServeSetup(
        servingTeamIndex: _servingTeamIndex!,
        servingPlayerIndex: _servingPlayerIndex ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final members = _servingTeamIndex == null
        ? <dynamic>[]
        : widget.config.membersForTeam(_servingTeamIndex!);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.marginMobile,
        12,
        AppTheme.marginMobile,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(
            'Кто подаёт первым?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Соперники должны знать, кто начинает подачу',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Text(
            'КОМАНДА',
            style: AppTheme.labelCaps(
              scheme,
              color: AppTheme.secondary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GlassSelectTile(
                  label: widget.config.team1Name,
                  selected: _servingTeamIndex == 0,
                  onTap: () => setState(() {
                    _servingTeamIndex = 0;
                    _servingPlayerIndex = _isDoubles ? null : 0;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassSelectTile(
                  label: widget.config.team2Name,
                  selected: _servingTeamIndex == 1,
                  onTap: () => setState(() {
                    _servingTeamIndex = 1;
                    _servingPlayerIndex = _isDoubles ? null : 0;
                  }),
                ),
              ),
            ],
          ),
          if (_isDoubles && _servingTeamIndex != null) ...[
            const SizedBox(height: 20),
            Text(
              'ИГРОК',
              style: AppTheme.labelCaps(
                scheme,
                color: AppTheme.secondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(members.length, (index) {
              final member = members[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassSelectTile(
                  label: member.displayWithSide,
                  selected: _servingPlayerIndex == index,
                  onTap: () => setState(() => _servingPlayerIndex = index),
                  centerText: false,
                ),
              );
            }),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _servingTeamIndex != null &&
                    (!_isDoubles || _servingPlayerIndex != null)
                ? _confirm
                : null,
            child: const Text('НАЧАТЬ ИГРУ'),
          ),
        ],
      ),
    );
  }
}
