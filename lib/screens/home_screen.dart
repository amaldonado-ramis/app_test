import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:echobeat/theme.dart';
import 'package:echobeat/components/mini_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<_NavigationItem> _navItems = const [
    _NavigationItem(
      icon: Icons.search,
      label: 'Search',
      route: '/search',
    ),
    _NavigationItem(
      icon: Icons.favorite,
      label: 'Liked',
      route: '/liked',
    ),
    _NavigationItem(
      icon: Icons.queue_music,
      label: 'Playlists',
      route: '/playlists',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Navigator(
              key: GlobalKey<NavigatorState>(),
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => _buildCurrentScreen(),
                );
              },
            ),
          ),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: _navItems.map((item) => NavigationDestination(
            icon: Icon(item.icon),
            label: item.label,
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const _SearchTab();
      case 1:
        return const _LikedTab();
      case 2:
        return const _PlaylistsTab();
      default:
        return const _SearchTab();
    }
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Search Music'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context),
            ),
          ],
        ),
        SliverPadding(
          padding: AppSpacing.paddingLg,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎵 Welcome to EchoBeat',
                  style: context.textStyles.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Search for your favorite tracks and albums, stream music anonymously, and create your own playlists.',
                  style: context.textStyles.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton.icon(
                  onPressed: () => context.push('/search-results'),
                  icon: const Icon(Icons.search),
                  label: const Text('Start Searching'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About EchoBeat'),
        content: const Text(
          'EchoBeat is a fully anonymous music streaming app. '
          'All your data (liked songs, playlists) is stored locally on your device. '
          'No account required, no tracking, just music.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _LikedTab extends StatelessWidget {
  const _LikedTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('Liked Songs'),
        ),
        SliverFillRemaining(
          child: Center(
            child: TextButton.icon(
              onPressed: () => context.push('/liked'),
              icon: const Icon(Icons.favorite),
              label: const Text('View All Liked Songs'),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('Your Playlists'),
        ),
        SliverFillRemaining(
          child: Center(
            child: TextButton.icon(
              onPressed: () => context.push('/playlists'),
              icon: const Icon(Icons.queue_music),
              label: const Text('Manage Playlists'),
            ),
          ),
        ),
      ],
    );
  }
}
