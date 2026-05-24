import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../models/open_match.dart';
import '../../theme/app_theme.dart';

class CreateOpenMatchScreen extends StatefulWidget {
  const CreateOpenMatchScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<CreateOpenMatchScreen> createState() => _CreateOpenMatchScreenState();
}

class _CreateOpenMatchScreenState extends State<CreateOpenMatchScreen> {
  final _clubController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  OpenMatchFormat _format = OpenMatchFormat.doubles;
  String _level = 'B';
  DateTime _dateTime = DateTime.now().add(const Duration(days: 1));
  bool _loading = false;

  static const _levels = ['A', 'B+', 'B', 'C+', 'C'];

  @override
  void initState() {
    super.initState();
    final club = widget.appState.auth.currentUser?.club;
    if (club != null && club.isNotEmpty) {
      _clubController.text = club;
    }
  }

  @override
  void dispose() {
    _clubController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final error = await widget.appState.openMatches.create(
      club: _clubController.text,
      address: _addressController.text,
      dateTime: _dateTime,
      level: _level,
      format: _format,
      note: _noteController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open match')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        children: [
          TextField(
            controller: _clubController,
            decoration: const InputDecoration(labelText: 'Клуб'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Адрес'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Дата и время'),
            subtitle: Text(
              '${_dateTime.day.toString().padLeft(2, '0')}.'
              '${_dateTime.month.toString().padLeft(2, '0')} '
              '${_dateTime.hour.toString().padLeft(2, '0')}:'
              '${_dateTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDateTime,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _levels.map((level) {
              return ChoiceChip(
                label: Text(level),
                selected: _level == level,
                onSelected: (_) => setState(() => _level = level),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SegmentedButton<OpenMatchFormat>(
            segments: const [
              ButtonSegment(
                value: OpenMatchFormat.doubles,
                label: Text('2×2'),
              ),
              ButtonSegment(
                value: OpenMatchFormat.singles,
                label: Text('1×1'),
              ),
            ],
            selected: {_format},
            onSelectionChanged: (v) => setState(() => _format = v.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Комментарий',
              hintText: 'Например: нужен 4-й, уровень B+',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Опубликовать'),
          ),
        ],
      ),
    );
  }
}
