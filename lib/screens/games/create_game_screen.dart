import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_state.dart';
import '../../models/deuce_rule.dart';
import '../../models/game_format.dart';
import '../../models/match_config.dart';
import '../../models/match_mode.dart';
import '../../models/player.dart';
import '../../models/team_member.dart';
import '../../widgets/player_avatar.dart';
import '../../widgets/team_slot_picker.dart';
import 'active_game_screen.dart';
import 'serve_selection_dialog.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  MatchMode _mode = MatchMode.standard;
  GameFormat _format = GameFormat.doubles2x2;
  DeuceRule _deuceRule = DeuceRule.advantage;
  TeamMember? _team1Left;
  TeamMember? _team1Right;
  TeamMember? _team2Left;
  TeamMember? _team2Right;
  TeamMember? _team1Single;
  TeamMember? _team2Single;
  String? _selectedSlot;
  final _searchController = TextEditingController();
  final _totalPointsController = TextEditingController(text: '50');
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _totalPointsController.dispose();
    super.dispose();
  }

  List<Player> get _filteredPlayers {
    final q = _searchQuery.toLowerCase();
    return widget.appState.social.allPlayers.where((p) {
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.club.toLowerCase().contains(q);
    }).toList();
  }

  Set<String> get _assignedIds => {
        _team1Left?.playerId,
        _team1Right?.playerId,
        _team2Left?.playerId,
        _team2Right?.playerId,
        _team1Single?.playerId,
        _team2Single?.playerId,
      }.whereType<String>().toSet();

  bool get _teamsComplete {
    if (_format == GameFormat.singles1x1) {
      return _team1Single != null && _team2Single != null;
    }
    return _team1Left != null &&
        _team1Right != null &&
        _team2Left != null &&
        _team2Right != null;
  }

  List<TeamMember> get _team1Members {
    if (_format == GameFormat.singles1x1) {
      return _team1Single == null ? [] : [_team1Single!];
    }
    return [_team1Left!, _team1Right!];
  }

  List<TeamMember> get _team2Members {
    if (_format == GameFormat.singles1x1) {
      return _team2Single == null ? [] : [_team2Single!];
    }
    return [_team2Left!, _team2Right!];
  }

  Future<void> _startGame() async {
    if (!_teamsComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _format == GameFormat.doubles2x2
                ? 'Заполните все 4 позиции в командах'
                : 'Выберите двух участников',
          ),
        ),
      );
      return;
    }

    final totalPoints = int.tryParse(_totalPointsController.text) ?? 50;
    final config = MatchConfig(
      mode: _mode,
      gameFormat: _format,
      team1Name: MatchConfig.teamLabel(_team1Members),
      team2Name: MatchConfig.teamLabel(_team2Members),
      team1Members: _team1Members,
      team2Members: _team2Members,
      participantIds: [
        ..._team1Members.map((m) => m.playerId),
        ..._team2Members.map((m) => m.playerId),
      ],
      totalPoints: totalPoints,
      minPointLead: 2,
      deuceRule: _deuceRule,
    );

    final serveSetup = await showServeSelectionDialog(context, config);
    if (serveSetup == null || !mounted) return;

    final game = widget.appState.games.createGame(
      config,
      servingTeamIndex: serveSetup.servingTeamIndex,
      servingPlayerIndex: serveSetup.servingPlayerIndex,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ActiveGameScreen(
          appState: widget.appState,
          gameId: game.id,
        ),
      ),
    );
  }

  void _assignPlayer(Player player) {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите позицию в команде')),
      );
      return;
    }

    if (_assignedIds.contains(player.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Игрок уже добавлен в команду')),
      );
      return;
    }

    final member = TeamMember.fromPlayer(
      player,
      side: _sideForSlot(_selectedSlot!),
    );

    setState(() {
      switch (_selectedSlot) {
        case 't1l':
          _team1Left = member;
        case 't1r':
          _team1Right = member;
        case 't2l':
          _team2Left = member;
        case 't2r':
          _team2Right = member;
        case 't1':
          _team1Single = member;
        case 't2':
          _team2Single = member;
      }
    });
  }

  CourtSide? _sideForSlot(String slot) {
    return switch (slot) {
      't1l' || 't2l' => CourtSide.left,
      't1r' || 't2r' => CourtSide.right,
      _ => null,
    };
  }

  void _clearSlot(String slot) {
    setState(() {
      switch (slot) {
        case 't1l':
          _team1Left = null;
        case 't1r':
          _team1Right = null;
        case 't2l':
          _team2Left = null;
        case 't2r':
          _team2Right = null;
        case 't1':
          _team1Single = null;
        case 't2':
          _team2Single = null;
      }
      _selectedSlot = slot;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = widget.appState.social.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Новая игра')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Формат', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<GameFormat>(
            segments: GameFormat.values
                .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                .toList(),
            selected: {_format},
            onSelectionChanged: (v) => setState(() {
              _format = v.first;
              _team1Left = _team1Right = _team2Left = _team2Right = null;
              _team1Single = _team2Single = null;
              _selectedSlot = null;
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _format.subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          Text('Пресет', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<MatchMode>(
            segments: MatchMode.values
                .map((m) => ButtonSegment(value: m, label: Text(m.title)))
                .toList(),
            selected: {_mode},
            onSelectionChanged: (v) => setState(() => _mode = v.first),
          ),
          if (_mode == MatchMode.standard) ...[
            const SizedBox(height: 20),
            Text('Deuce', style: Theme.of(context).textTheme.titleMedium),
            ...DeuceRule.values.map((rule) {
              return RadioListTile<DeuceRule>(
                value: rule,
                groupValue: _deuceRule,
                onChanged: (v) => setState(() => _deuceRule = v!),
                title: Text(rule.title),
                subtitle: Text(rule.subtitle),
              );
            }),
          ] else ...[
            const SizedBox(height: 20),
            TextField(
              controller: _totalPointsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Сумма очков'),
            ),
          ],
          const SizedBox(height: 20),
          Text('Команды', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Выберите позицию, затем игрока из списка',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TeamSlotPicker(
            gameFormat: _format,
            team1Left: _team1Left,
            team1Right: _team1Right,
            team2Left: _team2Left,
            team2Right: _team2Right,
            team1Single: _team1Single,
            team2Single: _team2Single,
            selectedSlot: _selectedSlot,
            onSlotTap: (slot) => setState(() {
              final member = _memberForSlot(slot);
              if (member != null) {
                _clearSlot(slot);
              } else {
                _selectedSlot = slot;
              }
            }),
          ),
          if (favorites.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Избранные', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final p = favorites[index];
                  return _PlayerPickTile(
                    player: p,
                    selected: _assignedIds.contains(p.id),
                    onTap: () => _assignPlayer(p),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Поиск участника',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 12),
          ..._filteredPlayers.map((p) {
            final slot = playerSlotLabel(
              format: _format,
              t1l: _team1Left,
              t1r: _team1Right,
              t2l: _team2Left,
              t2r: _team2Right,
              t1s: _team1Single,
              t2s: _team2Single,
              player: p,
            );
            return ListTile(
              leading: PlayerAvatar(player: p, radius: 18),
              title: Text(p.name),
              subtitle: Text('${p.rating} · ${p.club}'),
              trailing: slot != null ? Chip(label: Text(slot)) : null,
              onTap: () => _assignPlayer(p),
            );
          }),
          const SizedBox(height: 24),
          FilledButton(onPressed: _startGame, child: const Text('Далее')),
        ],
      ),
    );
  }

  TeamMember? _memberForSlot(String slot) {
    return switch (slot) {
      't1l' => _team1Left,
      't1r' => _team1Right,
      't2l' => _team2Left,
      't2r' => _team2Right,
      't1' => _team1Single,
      't2' => _team2Single,
      _ => null,
    };
  }
}

class _PlayerPickTile extends StatelessWidget {
  const _PlayerPickTile({
    required this.player,
    required this.selected,
    required this.onTap,
  });

  final Player player;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
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
