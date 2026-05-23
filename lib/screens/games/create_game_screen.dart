import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_state.dart';
import '../../models/deuce_rule.dart';
import '../../models/game_format.dart';
import '../../models/match_config.dart';
import '../../models/match_mode.dart';
import '../../models/player.dart';
import '../../models/team_member.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_select_tile.dart';
import '../../widgets/team_slot_picker.dart';
import 'active_game_screen.dart';
import 'player_selection_sheet.dart';
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
  final _totalPointsController = TextEditingController(text: '50');

  @override
  void dispose() {
    _totalPointsController.dispose();
    super.dispose();
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

  Future<void> _pickPlayerForSlot(String slot) async {
    final currentMember = _memberForSlot(slot);
    final result = await showPlayerSelectionSheet(
      context,
      slotTitle: _slotTitle(slot),
      allPlayers: widget.appState.social.allPlayers,
      favorites: widget.appState.social.favorites,
      assignedIds: _assignedIds,
      currentPlayerId: currentMember?.playerId,
    );

    if (!mounted || result == null) return;

    if (result is ClearPlayerSlot) {
      setState(() => _clearSlot(slot));
      return;
    }

    if (result is! Player) return;

    final member = TeamMember.fromPlayer(
      result,
      side: _sideForSlot(slot),
    );

    setState(() => _setMemberForSlot(slot, member));
  }

  String _slotTitle(String slot) {
    return switch (slot) {
      't1l' => 'Команда 1 · ${CourtSide.left.label}',
      't1r' => 'Команда 1 · ${CourtSide.right.label}',
      't2l' => 'Команда 2 · ${CourtSide.left.label}',
      't2r' => 'Команда 2 · ${CourtSide.right.label}',
      't1' => 'Команда 1',
      't2' => 'Команда 2',
      _ => 'Позиция',
    };
  }

  CourtSide? _sideForSlot(String slot) {
    return switch (slot) {
      't1l' || 't2l' => CourtSide.left,
      't1r' || 't2r' => CourtSide.right,
      _ => null,
    };
  }

  void _setMemberForSlot(String slot, TeamMember member) {
    switch (slot) {
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
  }

  void _clearSlot(String slot) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая игра')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        children: [
          _SectionLabel('ФОРМАТ'),
          const SizedBox(height: 8),
          Row(
            children: GameFormat.values.map((format) {
              final isLast = format == GameFormat.values.last;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 8),
                  child: GlassSelectTile(
                    label: format.label,
                    subtitle: format.subtitle,
                    selected: _format == format,
                    onTap: () => setState(() {
                      _format = format;
                      _team1Left = _team1Right = _team2Left = _team2Right = null;
                      _team1Single = _team2Single = null;
                    }),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _SectionLabel('ПРЕСЕТ'),
          const SizedBox(height: 8),
          Row(
            children: MatchMode.values.map((mode) {
              final isLast = mode == MatchMode.values.last;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 8),
                  child: GlassSelectTile(
                    label: mode.title,
                    selected: _mode == mode,
                    onTap: () => setState(() => _mode = mode),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_mode == MatchMode.standard) ...[
            const SizedBox(height: 20),
            _SectionLabel('DEUCE'),
            const SizedBox(height: 8),
            ...DeuceRule.values.map((rule) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassSelectTile(
                  label: rule.title,
                  subtitle: rule.subtitle,
                  selected: _deuceRule == rule,
                  onTap: () => setState(() => _deuceRule = rule),
                  centerText: false,
                ),
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
          _SectionLabel('КОМАНДЫ'),
          const SizedBox(height: 4),
          Text(
            'Нажмите на позицию, чтобы выбрать игрока',
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
            onSlotTap: _pickPlayerForSlot,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _startGame, child: const Text('ДАЛЕЕ')),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.labelCaps(
        Theme.of(context).colorScheme,
        color: AppTheme.secondary.withValues(alpha: 0.6),
      ),
    );
  }
}
