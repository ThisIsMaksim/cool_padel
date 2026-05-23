import 'package:flutter/material.dart';

import '../../models/game_format.dart';
import '../../models/match_config.dart';

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
    final members = _servingTeamIndex == null
        ? <dynamic>[]
        : widget.config.membersForTeam(_servingTeamIndex!);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Кто подаёт первым?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Соперники должны знать, кто начинает подачу',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          Text('Команда', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TeamServeOption(
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
                child: _TeamServeOption(
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
            Text('Игрок', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...List.generate(members.length, (index) {
              final member = members[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TeamServeOption(
                  label: member.displayWithSide,
                  selected: _servingPlayerIndex == index,
                  onTap: () => setState(() => _servingPlayerIndex = index),
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
            child: const Text('Начать игру'),
          ),
        ],
      ),
    );
  }
}

class _TeamServeOption extends StatelessWidget {
  const _TeamServeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
