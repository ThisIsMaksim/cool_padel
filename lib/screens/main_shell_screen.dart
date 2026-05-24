import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../widgets/whoop_bottom_nav.dart';
import 'club/club_home_tab.dart';
import 'games/create_game_screen.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final error = widget.appState.bootstrapError;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });
  }

  void _openCreateGame() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateGameScreen(appState: widget.appState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClub = widget.appState.auth.currentUser?.isClub ?? false;
    final tabs = [
      isClub
          ? ClubHomeTab(
              appState: widget.appState,
              onOpenProfile: () => setState(() => _currentIndex = 4),
            )
          : HomeTab(
              appState: widget.appState,
              onOpenProfile: () => setState(() => _currentIndex = 4),
            ),
      TournamentsTab(appState: widget.appState),
      GamesTab(appState: widget.appState),
      RatingTab(appState: widget.appState),
      ProfileTab(appState: widget.appState),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: tabs),
      extendBody: true,
      bottomNavigationBar: WhoopBottomNav(
        selectedIndex: _currentIndex,
        onSelected: (index) => setState(() => _currentIndex = index),
        onFabPressed: _openCreateGame,
      ),
    );
  }
}
