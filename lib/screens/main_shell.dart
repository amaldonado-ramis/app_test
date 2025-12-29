import 'package:echostream/screens/home_screen.dart';
import 'package:echostream/screens/library_screen.dart';
import 'package:echostream/screens/search_screen.dart';
import 'package:echostream/widgets/mini_player.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                selectedIcon: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                selectedIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                selectedIcon: Icon(Icons.library_music, color: Theme.of(context).colorScheme.primary),
                label: 'Library',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
