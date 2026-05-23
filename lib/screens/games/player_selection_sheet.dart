import 'package:flutter/material.dart';

import '../../models/player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_select_tile.dart';
import '../../widgets/player_avatar.dart';

/// Sentinel returned when the user clears the slot.
class ClearPlayerSlot {
  const ClearPlayerSlot();
}

const clearPlayerSlot = ClearPlayerSlot();

enum _PlayerListTab { all, favorites }

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
  _PlayerListTab _tab = _PlayerListTab.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isAvailable(Player player) {
    if (player.id == widget.currentPlayerId) return true;
    return !widget.assignedIds.contains(player.id);
  }

  bool _matchesSearch(Player player) {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return true;
    return player.name.toLowerCase().contains(q) ||
        player.club.toLowerCase().contains(q);
  }

  List<Player> get _visiblePlayers {
    final source =
        _tab == _PlayerListTab.all ? widget.allPlayers : widget.favorites;

    return source.where((p) => _isAvailable(p) && _matchesSearch(p)).toList();
  }

  String get _emptyMessage {
    if (_tab == _PlayerListTab.favorites && widget.favorites.isEmpty) {
      return 'В избранном пока никого нет';
    }
    if (_searchQuery.isNotEmpty) {
      return 'Участники не найдены';
    }
    return _tab == _PlayerListTab.favorites
        ? 'Нет доступных избранных игроков'
        : 'Участники не найдены';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final players = _visiblePlayers;

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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GlassSelectTile(
                  label: 'Все',
                  selected: _tab == _PlayerListTab.all,
                  onTap: () => setState(() => _tab = _PlayerListTab.all),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GlassSelectTile(
                  label: 'Избранные',
                  selected: _tab == _PlayerListTab.favorites,
                  onTap: () => setState(() => _tab = _PlayerListTab.favorites),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: players.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      _emptyMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: players.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final player = players[index];
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
