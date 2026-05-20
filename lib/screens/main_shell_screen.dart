import 'package:flutter/material.dart';

import '../state/games_repository.dart';
import 'tabs/games_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/tournaments_tab.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key, required this.gamesRepository});

  final GamesRepository gamesRepository;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gamesRepository,
      builder: (context, _) {
        final tabs = [
          HomeTab(gamesRepository: widget.gamesRepository),
          const TournamentsTab(),
          GamesTab(gamesRepository: widget.gamesRepository),
          const ProfileTab(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: tabs,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Главная',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Турниры',
              ),
              NavigationDestination(
                icon: Icon(Icons.sports_tennis_outlined),
                selectedIcon: Icon(Icons.sports_tennis),
                label: 'Игры',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Профиль',
              ),
            ],
          ),
        );
      },
    );
  }
}
