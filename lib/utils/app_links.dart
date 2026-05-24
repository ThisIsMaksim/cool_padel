import 'package:flutter/foundation.dart';

abstract final class AppLinks {
  static String tournament(String id) {
    if (kIsWeb) {
      return '${Uri.base.origin}/t/$id';
    }
    return 'https://130-193-59-193.sslip.io/t/$id';
  }

  static String? parseTournamentId(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 't') {
      return segments[1];
    }
    return null;
  }
}
