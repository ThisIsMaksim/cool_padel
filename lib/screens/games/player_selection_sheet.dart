import 'package:flutter/material.dart';

import '../../models/player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/player_avatar.dart';

/// Sentinel returned when the user clears the slot.
class ClearPlayerSlot {
  const ClearPlayerSlot();
}

const clearPlayerSlot = ClearPlayerSlot();

Future<Object?> showPlayerSelectionSheet(
  BuildContext context, {
  required String slotTitle,
  required List<Player> allPlayers,
  required List<Player> favorites,
  required Set<String> assignedIds,
  String? currentPlayerId,
}) {
  return showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
    ),
    builder: (ctx) => _PlayerSelectionSheet(
      slotTitle: slotTitle,
      allPlayers: allPlayers,
      favorites: favorites,
      assignedIds: assignedIds,
      currentPlayerId: currentPlayerId,
    ),
  );
}

class _PlayerSelectionSheet extends StatefulWidget {
  const _PlayerSelectionSheet({
    required this.slotTitle,
    required this.allPlayers,
    required this.favorites,
    required this.assignedIds,
    required this.currentPlayerId,
  });

  final String slotTitle;
  final List<Player> allPlayers;
  final List<Player> favorites;
  final Set<String> assignedIds;
  final String? currentPlayerId;

  @override
  State<_PlayerSelectionSheet> createState() => _PlayerSelectionSheetState();
}

class _PlayerSelectionSheetState extends State<_PlayerSelectionSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isAvailable(Player player) {
    if (player.id == widget.currentPlayerId) return true;
    return !widget.assignedIds.contains(player.id);
  }

  List<Player> get _filteredPlayers {
    final q = _searchQuery.toLowerCase();
    return widget.allPlayers.where((p) {
      if (!_isAvailable(p)) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.club.toLowerCase().contains(q);
    }).toList();
  }

  List<Player> get _availableFavorites =>
      widget.favorites.where(_isAvailable).toList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.marginMobile,
        12,
        AppTheme.marginMobile,
        24 + bottomInset,
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
            widget.slotTitle.toUpperCase(),
            style: AppTheme.labelCaps(
              scheme,
              color: AppTheme.secondary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Выберите участника',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Поиск участника',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          if (_availableFavorites.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'ИЗБРАННЫЕ',
              style: AppTheme.labelCaps(
                scheme,
                color: AppTheme.secondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableFavorites.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final player = _availableFavorites[index];
                  return _FavoriteTile(
                    player: player,
                    onTap: () => Navigator.pop(context, player),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: _filteredPlayers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Участники не найдены',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filteredPlayers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final player = _filteredPlayers[index];
                      final isCurrent = player.id == widget.currentPlayerId;
                      return AppTheme.glassSurface(
                        glow: isCurrent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        onTap: () => Navigator.pop(context, player),
                        child: Row(
                          children: [
                            PlayerAvatar(player: player, radius: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.name,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${player.rating} · ${player.club}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Text(
                                'ТЕКУЩИЙ',
                                style: AppTheme.labelCaps(
                                  scheme,
                                  color: AppTheme.primary,
                                ).copyWith(fontSize: 10),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (widget.currentPlayerId != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context, clearPlayerSlot),
              child: const Text('УБРАТЬ ИГРОКА'),
            ),
          ],
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.player,
    required this.onTap,
  });

  final Player player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTheme.glassSurface(
      radius: AppTheme.radiusMd,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayerAvatar(player: player, radius: 16),
            const SizedBox(height: 4),
            Text(
              player.name.split(' ').first,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
