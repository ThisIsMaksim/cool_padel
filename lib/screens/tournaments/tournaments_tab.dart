import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/tournament.dart';
import 'create_tournament_screen.dart';
import 'tournament_detail_screen.dart';

class TournamentsTab extends StatefulWidget {
  const TournamentsTab({super.key, required this.appState});

  final AppState appState;

  @override
  State<TournamentsTab> createState() => _TournamentsTabState();
}

class _TournamentsTabState extends State<TournamentsTab> {
  String _day = 'Все';
  String _level = 'Все';
  String _club = 'Все';
  TournamentFormat? _format;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState.social,
      builder: (context, _) {
        final active = widget.appState.social.activeTournaments;
        final filtered = widget.appState.social.filterTournaments(
          day: _day,
          level: _level,
          format: _format,
          club: _club,
        );
        final clubs = widget.appState.social.tournamentClubs;

        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Турниры',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Создать турнир',
                        onPressed: _openCreate,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              ),
              if (active.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      'Активные сейчас',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 130,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: active.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final t = active[index];
                      return _ActiveTournamentChip(
                        tournament: t,
                        onTap: () => _openDetail(t.id),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: _FiltersBar(
                    day: _day,
                    level: _level,
                    club: _club,
                    format: _format,
                    clubs: clubs,
                    onChanged: (day, level, club, format) {
                      setState(() {
                        _day = day;
                        _level = level;
                        _club = club;
                        _format = format;
                      });
                    },
                  ),
                ),
              ),
              SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final t = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _TournamentTile(
                      tournament: t,
                      onTap: () => _openDetail(t.id),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }

  void _openDetail(String id) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TournamentDetailScreen(
          appState: widget.appState,
          tournamentId: id,
        ),
      ),
    );
  }

  void _openCreate() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateTournamentScreen(appState: widget.appState),
      ),
    );
  }
}

class _ActiveTournamentChip extends StatelessWidget {
  const _ActiveTournamentChip({required this.tournament, required this.onTap});

  final Tournament tournament;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tournament.title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${tournament.freeSlots} мест',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.day,
    required this.level,
    required this.club,
    required this.format,
    required this.clubs,
    required this.onChanged,
  });

  final String day;
  final String level;
  final String club;
  final TournamentFormat? format;
  final List<String> clubs;
  final void Function(String, String, String, TournamentFormat?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          label: 'День: $day',
          onTap: () => _pick(context, 'День',
              ['Все', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'], day, (v) {
            onChanged(v, level, club, format);
          }),
        ),
        _FilterChip(
          label: 'Уровень: $level',
          onTap: () => _pick(context, 'Уровень',
              ['Все', 'A', 'B+', 'B', 'C+', 'C'], level, (v) {
            onChanged(day, v, club, format);
          }),
        ),
        _FilterChip(
          label: 'Клуб: $club',
          onTap: () => _pick(context, 'Клуб', [
            'Все',
            ...clubs,
          ], club, (v) {
            onChanged(day, level, v, format);
          }),
        ),
        FilterChip(
          label: Text(format == TournamentFormat.doubles
              ? 'Парный'
              : format == TournamentFormat.singles
                  ? 'Одиночный'
                  : 'Формат'),
          selected: format != null,
          onSelected: (_) {
            final next = format == null
                ? TournamentFormat.doubles
                : format == TournamentFormat.doubles
                    ? TournamentFormat.singles
                    : null;
            onChanged(day, level, club, next);
          },
        ),
      ],
    );
  }

  Future<void> _pick(
    BuildContext context,
    String title,
    List<String> options,
    String current,
    ValueChanged<String> onSelect,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => ListView(
        children: options
            .map((o) => ListTile(
                  title: Text(o),
                  trailing: o == current ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(ctx, o),
                ))
            .toList(),
      ),
    );
    if (selected != null) onSelect(selected);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _TournamentTile extends StatelessWidget {
  const _TournamentTile({required this.tournament, required this.onTap});

  final Tournament tournament;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tournament.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Chip(label: Text(tournament.level)),
                ],
              ),
              const SizedBox(height: 8),
              Text('${tournament.club} · ${tournament.formatLabel}'),
              Text(
                _formatDate(tournament.dateTime),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                tournament.isFull
                    ? 'Мест нет · лист ожидания'
                    : 'Свободно мест: ${tournament.freeSlots}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
