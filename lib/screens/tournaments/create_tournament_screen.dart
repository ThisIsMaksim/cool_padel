import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_state.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_select_tile.dart';
import 'tournament_detail_screen.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clubController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '16');

  TournamentFormat _format = TournamentFormat.doubles;
  String _level = 'B';
  DateTime _dateTime = DateTime.now().add(const Duration(days: 3));
  bool _isSubmitting = false;

  static const _levels = ['A', 'B+', 'B', 'C+', 'C'];

  @override
  void initState() {
    super.initState();
    final userClub = widget.appState.auth.currentUser?.club;
    if (userClub != null && userClub.isNotEmpty) {
      _clubController.text = userClub;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clubController.dispose();
    _addressController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final club = _clubController.text.trim();
    final address = _addressController.text.trim();
    final maxParticipants = int.tryParse(_maxParticipantsController.text) ?? 0;

    if (title.length < 3) {
      _showError('Название — минимум 3 символа');
      return;
    }
    if (description.length < 10) {
      _showError('Описание — минимум 10 символов');
      return;
    }
    if (club.length < 2) {
      _showError('Укажите клуб');
      return;
    }
    if (address.length < 3) {
      _showError('Укажите адрес');
      return;
    }
    if (maxParticipants < 2) {
      _showError('Минимум 2 участника');
      return;
    }
    if (_format == TournamentFormat.doubles && maxParticipants.isOdd) {
      _showError('Для парного турнира число участников должно быть чётным');
      return;
    }
    if (!_dateTime.isAfter(DateTime.now())) {
      _showError('Дата турнира должна быть в будущем');
      return;
    }

    setState(() => _isSubmitting = true);

    final (error, created) = await widget.appState.social.createTournament(
      title: title,
      description: description,
      club: club,
      address: address,
      dateTime: _dateTime,
      level: _level,
      format: _format,
      maxParticipants: maxParticipants,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null || created == null) {
      _showError(error ?? 'Не удалось создать турнир');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TournamentDetailScreen(
          appState: widget.appState,
          tournamentId: created.id,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый турнир')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        children: [
          const _SectionLabel('ОСНОВНОЕ'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Название'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Описание'),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          const _SectionLabel('МЕСТО'),
          const SizedBox(height: 8),
          TextField(
            controller: _clubController,
            decoration: const InputDecoration(labelText: 'Клуб'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Адрес'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          const _SectionLabel('ДАТА И ВРЕМЯ'),
          const SizedBox(height: 8),
          GlassSelectTile(
            label: _formatDateTime(_dateTime),
            subtitle: 'Нажмите, чтобы изменить',
            selected: true,
            onTap: _pickDateTime,
            centerText: false,
          ),
          const SizedBox(height: 20),
          const _SectionLabel('ФОРМАТ'),
          const SizedBox(height: 8),
          Row(
            children: TournamentFormat.values.map((format) {
              final isLast = format == TournamentFormat.values.last;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 8),
                  child: GlassSelectTile(
                    label: format == TournamentFormat.doubles
                        ? 'Парный'
                        : 'Одиночный',
                    selected: _format == format,
                    onTap: () => setState(() => _format = format),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('УРОВЕНЬ'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _levels.map((level) {
              return ChoiceChip(
                label: Text(level),
                selected: _level == level,
                onSelected: (_) => setState(() => _level = level),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _maxParticipantsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Максимум участников',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('СОЗДАТЬ'),
          ),
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
