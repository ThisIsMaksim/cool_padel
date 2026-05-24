import 'package:flutter/foundation.dart';

import '../models/open_match.dart';
import '../services/api_client.dart';

class OpenMatchesRepository extends ChangeNotifier {
  OpenMatchesRepository(this._api);

  final ApiClient _api;

  List<OpenMatch> _open = [];
  List<OpenMatch> _mine = [];

  List<OpenMatch> get openMatches => List.unmodifiable(_open);

  List<OpenMatch> get myMatches => List.unmodifiable(_mine);

  Future<void> load() async {
    _requireAuth();
    final results = await Future.wait([
      _api.getList('/open-matches'),
      _api.getList('/open-matches/mine'),
    ]);
    _open = results[0]
        .whereType<Map<String, dynamic>>()
        .map(OpenMatch.fromJson)
        .toList();
    _mine = results[1]
        .whereType<Map<String, dynamic>>()
        .map(OpenMatch.fromJson)
        .toList();
    notifyListeners();
  }

  Future<String?> create({
    required String club,
    required String address,
    required DateTime dateTime,
    required String level,
    required OpenMatchFormat format,
    String? note,
  }) async {
    _requireAuth();
    try {
      final json = await _api.post('/open-matches', body: {
        'club': club,
        'address': address,
        'dateTime': dateTime.toUtc().toIso8601String(),
        'level': level,
        'format': format.name,
        if (note != null && note.isNotEmpty) 'note': note,
      });
      final created = OpenMatch.fromJson(json);
      _open = [..._open, created]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _mine = [created, ..._mine];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> join(String id) async {
    _requireAuth();
    try {
      final json = await _api.patch('/open-matches/$id/join');
      _upsert(OpenMatch.fromJson(json));
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  OpenMatch? byId(String id) {
    for (final m in [..._open, ..._mine]) {
      if (m.id == id) return m;
    }
    return null;
  }

  void _upsert(OpenMatch match) {
    _open = _replaceInList(_open, match);
    _mine = _replaceInList(_mine, match);
  }

  List<OpenMatch> _replaceInList(List<OpenMatch> list, OpenMatch match) {
    final index = list.indexWhere((m) => m.id == match.id);
    if (index == -1) return [...list, match];
    final next = [...list];
    next[index] = match;
    return next;
  }

  void _requireAuth() {
    if (_api.token == null) {
      throw ApiException('Требуется авторизация');
    }
  }
}
