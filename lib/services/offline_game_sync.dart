import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PendingGamePatch {
  PendingGamePatch({
    required this.gameId,
    required this.path,
    required this.body,
  });

  final String gameId;
  final String path;
  final Map<String, dynamic> body;

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'path': path,
        'body': body,
      };

  factory PendingGamePatch.fromJson(Map<String, dynamic> json) {
    return PendingGamePatch(
      gameId: json['gameId'] as String,
      path: json['path'] as String,
      body: Map<String, dynamic>.from(json['body'] as Map),
    );
  }
}

class OfflineGameSync {
  OfflineGameSync(this._prefs);

  static const _key = 'pending_game_patches_v1';

  final SharedPreferences _prefs;

  static Future<OfflineGameSync> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OfflineGameSync(prefs);
  }

  List<PendingGamePatch> loadQueue() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PendingGamePatch.fromJson)
        .toList();
  }

  Future<void> enqueue(PendingGamePatch patch) async {
    final queue = loadQueue()..add(patch);
    await _save(queue);
  }

  Future<void> replaceQueue(List<PendingGamePatch> queue) async {
    await _save(queue);
  }

  Future<void> _save(List<PendingGamePatch> queue) async {
    await _prefs.setString(
      _key,
      jsonEncode(queue.map((p) => p.toJson()).toList()),
    );
  }
}
