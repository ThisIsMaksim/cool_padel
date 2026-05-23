import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_state.dart';
import 'config/api_config.dart';
import 'repositories/auth_repository.dart';
import 'repositories/social_repository.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main_shell_screen.dart';
import 'services/api_client.dart';
import 'state/games_repository.dart';
import 'storage/games_storage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final api = ApiClient(baseUrl: ApiConfig.baseUrl);
  final storage = SharedPreferencesGamesStorage(prefs);
  final auth = await AuthRepository.create(api: api);
  final social = SocialRepository(prefs, api);
  final games = GamesRepository(storage: storage, api: api);

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
          theme: AppTheme.dark,
          home: home,
        );
      },
    );
  }
}
