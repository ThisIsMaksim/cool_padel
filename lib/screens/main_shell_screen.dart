import 'package:flutter/material.dart';

import '../app/app_state.dart';
import 'games/games_tab.dart';
import 'home/home_tab.dart';
import 'profile/profile_tab.dart';
import 'rating/rating_tab.dart';
import 'tournaments/tournaments_tab.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(
        appState: widget.appState,
        onOpenProfile: () => setState(() => _currentIndex = 4),
      ),
      TournamentsTab(appState: widget.appState),
      GamesTab(appState: widget.appState),
      RatingTab(appState: widget.appState),
      ProfileTab(appState: widget.appState),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
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
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Рейтинг',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
