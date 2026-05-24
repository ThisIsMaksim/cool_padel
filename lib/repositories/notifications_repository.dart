import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../services/api_client.dart';

class NotificationsRepository extends ChangeNotifier {
  NotificationsRepository(this._api);

  final ApiClient _api;

  List<AppNotification> _items = [];
  int _unreadCount = 0;

  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _unreadCount;

  Future<void> load() async {
    _requireAuth();
    final results = await Future.wait([
      _api.getList('/notifications'),
      _api.get('/notifications/unread-count'),
    ]);
    _items = (results[0] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
    _unreadCount = (results[1] as Map<String, dynamic>)['count'] as int? ?? 0;
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    await _api.patch('/notifications/$id/read');
    _items = _items
        .map(
          (n) => n.id == id
              ? AppNotification(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  body: n.body,
                  linkPath: n.linkPath,
                  read: true,
                  createdAt: n.createdAt,
                )
              : n,
        )
        .toList();
    _unreadCount = _items.where((n) => !n.read).length;
    notifyListeners();
  }

  Future<void> markAllRead() async {
    await _api.patch('/notifications/read-all');
    await load();
  }

  void _requireAuth() {
    if (_api.token == null) {
      throw ApiException('Требуется авторизация');
    }
  }
}
