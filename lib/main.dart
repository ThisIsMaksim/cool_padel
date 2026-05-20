import 'package:flutter/material.dart';

import 'screens/main_shell_screen.dart';
import 'state/games_repository.dart';
import 'storage/games_storage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await SharedPreferencesGamesStorage.create();
  final gamesRepository = GamesRepository(storage: storage);
  await gamesRepository.load();

  runApp(CoolPadelApp(gamesRepository: gamesRepository));
}

class CoolPadelApp extends StatelessWidget {
  const CoolPadelApp({super.key, required this.gamesRepository});

  final GamesRepository gamesRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cool Padel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MainShellScreen(gamesRepository: gamesRepository),
    );
  }
}
