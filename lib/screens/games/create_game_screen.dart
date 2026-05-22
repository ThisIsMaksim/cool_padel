import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_state.dart';
import '../../models/deuce_rule.dart';
import '../../models/match_config.dart';
import '../../models/match_mode.dart';
import '../../models/player.dart';
import '../../widgets/player_avatar.dart';
import 'active_game_screen.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  MatchMode _mode = MatchMode.standard;
  DeuceRule _deuceRule = DeuceRule.advantage;
  Player? _team1Player;
  Player? _team2Player;
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

  void _startGame() {
    if (_team1Player == null || _team2Player == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите двух участников')),
      );
      return;
    }

    if (_team1Player!.id == _team2Player!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Участники должны быть разными')),
      );
      return;
    }

    final totalPoints = int.tryParse(_totalPointsController.text) ?? 50;

    final config = MatchConfig(
      mode: _mode,
      team1Name: _team1Player!.name,
      team2Name: _team2Player!.name,
      participantIds: [_team1Player!.id, _team2Player!.id],
      totalPoints: totalPoints,
      minPointLead: 2,
      deuceRule: _deuceRule,
    );

    final game = widget.appState.games.createGame(config);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ActiveGameScreen(
          appState: widget.appState,
          gameId: game.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = widget.appState.social.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Новая игра')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Пресет', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<MatchMode>(
            segments: MatchMode.values
                .map((m) => ButtonSegment(value: m, label: Text(m.title)))
                .toList(),
            selected: {_mode},
            onSelectionChanged: (v) => setState(() => _mode = v.first),
          ),
          const SizedBox(height: 8),
          Text(
            _mode == MatchMode.standard
                ? 'До 2 сетов, теннисный счёт 0-15-30-40'
                : 'До суммы очков, 1 мяч = 1 балл, победа при разнице 2',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_mode == MatchMode.standard) ...[
            const SizedBox(height: 20),
            Text('Deuce', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
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
          Text('Участники', style: Theme.of(context).textTheme.titleMedium),
          if (favorites.isNotEmpty) ...[
            const SizedBox(height: 8),
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
                    selected: _team1Player?.id == p.id || _team2Player?.id == p.id,
                    onTap: () => _pickPlayer(p),
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
          ..._filteredPlayers.map(
            (p) => ListTile(
              leading: PlayerAvatar(player: p, radius: 18),
              title: Text(p.name),
              subtitle: Text('${p.rating} · ${p.club}'),
              trailing: _team1Player?.id == p.id
                  ? const Chip(label: Text('К1'))
                  : _team2Player?.id == p.id
                      ? const Chip(label: Text('К2'))
                      : null,
              onTap: () => _pickPlayer(p),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _startGame, child: const Text('Начать игру')),
        ],
      ),
    );
  }

  void _pickPlayer(Player player) {
    setState(() {
      if (_team1Player?.id == player.id) {
        _team1Player = null;
        return;
      }
      if (_team2Player?.id == player.id) {
        _team2Player = null;
        return;
      }
      if (_team1Player == null) {
        _team1Player = player;
      } else if (_team2Player == null) {
        _team2Player = player;
      } else {
        _team2Player = player;
      }
    });
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
