import 'package:flutter/material.dart';

import '../../models/game_format.dart';
import '../../models/player.dart';
import '../../models/team_member.dart';

class TeamSlotPicker extends StatelessWidget {
  const TeamSlotPicker({
    super.key,
    required this.gameFormat,
    required this.team1Left,
    required this.team1Right,
    required this.team2Left,
    required this.team2Right,
    required this.team1Single,
    required this.team2Single,
    required this.selectedSlot,
    required this.onSlotTap,
  });

  final GameFormat gameFormat;
  final TeamMember? team1Left;
  final TeamMember? team1Right;
  final TeamMember? team2Left;
  final TeamMember? team2Right;
  final TeamMember? team1Single;
  final TeamMember? team2Single;
  final String? selectedSlot;
  final ValueChanged<String> onSlotTap;

  @override
  Widget build(BuildContext context) {
    if (gameFormat == GameFormat.singles1x1) {
      return Row(
        children: [
          Expanded(
            child: _SlotCard(
              label: 'Команда 1',
              member: team1Single,
              selected: selectedSlot == 't1',
              onTap: () => onSlotTap('t1'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SlotCard(
              label: 'Команда 2',
              member: team2Single,
              selected: selectedSlot == 't2',
              onTap: () => onSlotTap('t2'),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text('Команда 1', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SlotCard(
                label: CourtSide.left.label,
                member: team1Left,
                selected: selectedSlot == 't1l',
                onTap: () => onSlotTap('t1l'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SlotCard(
                label: CourtSide.right.label,
                member: team1Right,
                selected: selectedSlot == 't1r',
                onTap: () => onSlotTap('t1r'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Команда 2', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SlotCard(
                label: CourtSide.left.label,
                member: team2Left,
                selected: selectedSlot == 't2l',
                onTap: () => onSlotTap('t2l'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SlotCard(
                label: CourtSide.right.label,
                member: team2Right,
                selected: selectedSlot == 't2r',
                onTap: () => onSlotTap('t2r'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.label,
    required this.member,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final TeamMember? member;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
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
              : Colors.grey.shade50,
        ),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(
              member?.shortName ?? '—',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String? playerSlotLabel({
  required GameFormat format,
  required TeamMember? t1l,
  required TeamMember? t1r,
  required TeamMember? t2l,
  required TeamMember? t2r,
  required TeamMember? t1s,
  required TeamMember? t2s,
  required Player player,
}) {
  if (t1l?.playerId == player.id) return 'К1 · ${CourtSide.left.label}';
  if (t1r?.playerId == player.id) return 'К1 · ${CourtSide.right.label}';
  if (t2l?.playerId == player.id) return 'К2 · ${CourtSide.left.label}';
  if (t2r?.playerId == player.id) return 'К2 · ${CourtSide.right.label}';
  if (t1s?.playerId == player.id) return 'К1';
  if (t2s?.playerId == player.id) return 'К2';
  return null;
}
