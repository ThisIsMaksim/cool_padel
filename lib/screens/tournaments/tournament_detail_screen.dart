import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_state.dart';
import '../../models/player.dart';
import '../../models/tournament.dart';
import '../../utils/app_links.dart';
import '../../widgets/player_avatar.dart';

class TournamentDetailScreen extends StatefulWidget {
  const TournamentDetailScreen({
    super.key,
    required this.appState,
    required this.tournamentId,
  });

  final AppState appState;
  final String tournamentId;

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  String? _selectedPartnerId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState.social,
      builder: (context, _) {
        final tournament =
            widget.appState.social.tournamentById(widget.tournamentId);
        if (tournament == null) {
          return const Scaffold(
            body: Center(child: Text('Турнир не найден')),
          );
        }

        final organizer =
            widget.appState.social.playerById(tournament.organizerId);
        final participants = tournament.participantIds
            .map(widget.appState.social.playerById)
            .whereType<Player>()
            .toList();
        final userId = widget.appState.auth.currentUser?.id ?? 'player_1';
        final isRegistered = tournament.participantIds.contains(userId);
        final isWaitlisted = tournament.waitlistIds.contains(userId);

        return Scaffold(
          appBar: AppBar(
            title: Text(tournament.title),
            actions: [
              IconButton(
                tooltip: 'Поделиться',
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _shareTournament(tournament),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    QrImageView(
                      data: AppLinks.tournament(tournament.id),
                      size: 160,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'QR для регистрации',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: AppLinks.tournament(tournament.id),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ссылка скопирована')),
                        );
                      },
                      child: const Text('Копировать ссылку'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(tournament.description),
              const SizedBox(height: 16),
              _InfoRow(icon: Icons.place, text: tournament.address),
              _InfoRow(icon: Icons.home_work, text: tournament.club),
              _InfoRow(
                icon: Icons.calendar_today,
                text: _formatDate(tournament.dateTime),
              ),
              _InfoRow(
                icon: Icons.person,
                text: 'Организатор: ${organizer?.name ?? '—'}',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('Уровень ${tournament.level}')),
                  Chip(label: Text(tournament.formatLabel)),
                  Chip(
                    label: Text(
                      tournament.isFull ? 'Мест нет' : '${tournament.freeSlots} мест',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Участники (${participants.length}/${tournament.maxParticipants})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...participants.map(
                (p) => ListTile(
                  leading: PlayerAvatar(player: p),
                  title: Text(p.name),
                  trailing: Text('${p.rating}'),
                ),
              ),
              if (tournament.waitlistIds.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Лист ожидания: ${tournament.waitlistIds.length}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
              const SizedBox(height: 24),
              if (tournament.format == TournamentFormat.doubles &&
                  !isRegistered &&
                  !isWaitlisted) ...[
                Text(
                  'Партнёр',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPartnerId,
                  decoration: const InputDecoration(labelText: 'Пригласить партнёра'),
                  items: widget.appState.social.allPlayers
                      .where((p) => p.id != userId)
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} (${p.rating})'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPartnerId = v),
                ),
                const SizedBox(height: 16),
              ],
              if (!isRegistered)
                FilledButton(
                  onPressed: () => _register(tournament, userId),
                  child: Text(
                    tournament.isFull
                        ? 'Встать в лист ожидания'
                        : 'Записаться на турнир',
                  ),
                )
              else
                OutlinedButton(
                  onPressed: null,
                  child: const Text('Вы уже записаны'),
                ),
              if (isWaitlisted)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Вы в листе ожидания',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _register(Tournament tournament, String userId) async {
    final error = await widget.appState.social.registerForTournament(
      tournamentId: tournament.id,
      userId: userId,
      partnerId: _selectedPartnerId,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final onWaitlist = widget.appState.social
        .tournamentById(tournament.id)!
        .waitlistIds
        .contains(userId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          onWaitlist ? 'Добавлено в лист ожидания' : 'Вы записаны на турнир',
        ),
      ),
    );
    await widget.appState.notifications.load();
    setState(() {});
  }

  Future<void> _shareTournament(Tournament tournament) async {
    final link = AppLinks.tournament(tournament.id);
    final text =
        '${tournament.title}\n${tournament.club} · ${tournament.formatLabel}\n$link';
    await Share.share(text, subject: tournament.title);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
