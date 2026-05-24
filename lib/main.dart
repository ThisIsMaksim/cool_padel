import 'package:flutter/material.dart';

import 'app/app_state.dart';
import 'config/api_config.dart';
import 'repositories/auth_repository.dart';
import 'repositories/notifications_repository.dart';
import 'repositories/open_matches_repository.dart';
import 'repositories/social_repository.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/tournaments/tournament_detail_screen.dart';
import 'services/api_client.dart';
import 'services/offline_game_sync.dart';
import 'state/games_repository.dart';
import 'theme/app_theme.dart';
import 'utils/app_links.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiClient(baseUrl: ApiConfig.baseUrl);
  final offlineSync = await OfflineGameSync.create();
  final auth = await AuthRepository.create(api: api);
  final social = SocialRepository(api);
  final games = GamesRepository(api: api, offlineSync: offlineSync);
  final openMatches = OpenMatchesRepository(api);
  final notifications = NotificationsRepository(api);

  final appState = AppState(
    auth: auth,
    games: games,
    social: social,
    openMatches: openMatches,
    notifications: notifications,
  );

  final tournamentId = AppLinks.parseTournamentId(Uri.base);
  if (tournamentId != null) {
    appState.setPendingTournamentId(tournamentId);
  }

  await appState.initialize();

  runApp(CoolPadelApp(appState: appState));
}

class CoolPadelApp extends StatelessWidget {
  const CoolPadelApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState.auth,
      builder: (context, _) {
        return MaterialApp(
          title: 'CoolPadel',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: appState.auth.isAuthenticated
              ? _AuthenticatedRoot(appState: appState)
              : LoginScreen(appState: appState),
        );
      },
    );
  }
}

class _AuthenticatedRoot extends StatefulWidget {
  const _AuthenticatedRoot({required this.appState});

  final AppState appState;

  @override
  State<_AuthenticatedRoot> createState() => _AuthenticatedRootState();
}

class _AuthenticatedRootState extends State<_AuthenticatedRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPendingDeepLink());
  }

  void _openPendingDeepLink() {
    final id = widget.appState.pendingTournamentId;
    if (id == null || !mounted) return;
    widget.appState.setPendingTournamentId(null);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TournamentDetailScreen(
          appState: widget.appState,
          tournamentId: id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScreen(appState: widget.appState);
  }
}
