import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_state.dart';
import 'repositories/auth_repository.dart';
import 'repositories/social_repository.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main_shell_screen.dart';
import 'state/games_repository.dart';
import 'storage/games_storage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storage = SharedPreferencesGamesStorage(prefs);
  final auth = await AuthRepository.create();
  final social = SocialRepository(prefs);
  final games = GamesRepository(storage: storage);

  final appState = AppState(auth: auth, games: games, social: social);
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
        final home = appState.auth.isAuthenticated
            ? MainShellScreen(appState: appState)
            : LoginScreen(appState: appState);

        return MaterialApp(
          title: 'CoolPadel',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: home,
        );
      },
    );
  }
}
