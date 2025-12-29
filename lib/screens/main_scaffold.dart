import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rhapsody/widgets/mini_player.dart';
import 'package:rhapsody/providers/playback_provider.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // Watch playback provider to determine if mini player will be shown
    // We need this to add padding to the bottom of the screen so content isn't covered
    final hasActiveTrack = context.select<PlaybackProvider, bool>((p) => p.currentTrack != null);
    
    return Scaffold(
      extendBody: false,
      body: Stack(
        children: [
          navigationShell,
          
          // Mini Player
          // It handles its own visibility check internally, but we place it here in the stack
          const MiniPlayer(), 
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // A common pattern when using bottom navigation bars is to support
            // navigating to the initial location when tapping the item that is
            // already active.
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
