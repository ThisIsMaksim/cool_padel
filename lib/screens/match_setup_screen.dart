import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/match_config.dart';
import '../models/match_mode.dart';
import '../state/games_repository.dart';
import 'standard_match_screen.dart';
import 'tournament_match_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key, required this.gamesRepository});

  final GamesRepository gamesRepository;

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  MatchMode _mode = MatchMode.standard;
  final _team1Controller = TextEditingController(text: 'Команда 1');
  final _team2Controller = TextEditingController(text: 'Команда 2');
  final _totalPointsController = TextEditingController(text: '50');
  int _setsToWin = 2;

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    _totalPointsController.dispose();
    super.dispose();
  }

  void _startMatch() {
    final team1 = _team1Controller.text.trim();
    final team2 = _team2Controller.text.trim();

    if (team1.isEmpty || team2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите названия обеих команд')),
      );
      return;
    }

    final config = MatchConfig(
      mode: _mode,
      team1Name: team1,
      team2Name: team2,
      setsToWin: _setsToWin,
      totalPoints: int.tryParse(_totalPointsController.text) ?? 50,
    );

    if (_mode == MatchMode.tournament && config.totalPoints < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сумма очков должна быть не менее 2')),
      );
      return;
    }

    final game = widget.gamesRepository.createGame(config);

    final screen = _mode == MatchMode.standard
        ? StandardMatchScreen(
            game: game,
            gamesRepository: widget.gamesRepository,
          )
        : TournamentMatchScreen(
            game: game,
            gamesRepository: widget.gamesRepository,
          );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая игра')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Режим игры',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...MatchMode.values.map((mode) {
            final selected = _mode == mode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => _mode = mode),
                  child: Container(
                    decoration: BoxDecoration(
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          mode == MatchMode.standard
                              ? Icons.sports_score
                              : Icons.leaderboard,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mode.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(mode.subtitle),
                            ],
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text(
            'Команды',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _team1Controller,
            decoration: const InputDecoration(labelText: 'Команда 1'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _team2Controller,
            decoration: const InputDecoration(labelText: 'Команда 2'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          if (_mode == MatchMode.standard) ...[
            Text(
              'Сеты до победы',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('До 2')),
                ButtonSegment(value: 3, label: Text('До 3')),
              ],
              selected: {_setsToWin},
              onSelectionChanged: (value) {
                setState(() => _setsToWin = value.first);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Стандартные правила: геймы до 6, тай-брейк при 6:6, счёт 0-15-30-40.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else ...[
            Text(
              'Суммарное количество очков',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totalPointsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Всего очков в матче',
                helperText:
                    'Матч завершится, когда сумма очков достигнет этого числа',
              ),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _startMatch,
            child: const Text('Начать игру'),
          ),
        ],
      ),
    );
  }
}
