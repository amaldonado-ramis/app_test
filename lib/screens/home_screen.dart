import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rhapsody/providers/library_provider.dart';
import 'package:rhapsody/providers/playback_provider.dart';
import 'package:rhapsody/theme.dart';
import 'package:rhapsody/models/user_playlist.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    // final playback = context.watch<PlaybackProvider>(); // Not needed for UI layout anymore as we removed the big card

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: false,
            expandedHeight: 0,
            toolbarHeight: kToolbarHeight + 16,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Rhapsody',
                style: context.textStyles.headlineMedium?.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.search, size: 28),
                  onPressed: () => context.go('/search'),
                ),
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.horizontalMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _buildLibrarySection(context, library),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPlaylistsSection(context, library),
                  const SizedBox(height: AppSpacing.xl),
                  _buildDiscoverSection(context),
                  // Add bottom padding for MiniPlayer
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarySection(BuildContext context, LibraryProvider library) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Library', style: context.textStyles.titleLarge?.bold),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _LibraryCard(
                title: 'Liked Songs',
                subtitle: '${library.likedSongsCount} tracks',
                icon: Icons.favorite,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF450AF5),
                    Color(0xFFC4EFDA),
                  ],
                  stops: [0.3, 1.0],
                ),
                onTap: () => context.go('/library/playlist/liked'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaylistsSection(BuildContext context, LibraryProvider library) {
    if (library.playlists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Playlists', style: context.textStyles.titleLarge?.bold),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // TODO: Show create playlist dialog
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: library.playlists.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final playlist = library.playlists[index];
              return _PlaylistCard(playlist: playlist);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Discover', style: context.textStyles.titleLarge?.bold),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingXl,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.travel_explore,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Find your next favorite song',
                style: context.textStyles.titleMedium?.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Search for artists, albums, or tracks',
                style: context.textStyles.bodyMedium?.withColor(
                  Theme.of(context).colorScheme.onSurfaceVariant
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(
                onPressed: () => context.go('/search'),
                child: const Text('Start Searching'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: context.textStyles.titleMedium?.bold.withColor(Colors.white),
                  ),
                  Text(
                    subtitle,
                    style: context.textStyles.bodySmall?.withColor(Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final UserPlaylist playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/library/playlist/${playlist.id}'),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                ),
                child: Center(
                  child: Icon(
                    Icons.music_note,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: context.textStyles.titleSmall?.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${playlist.trackCount} tracks',
                    style: context.textStyles.bodySmall?.withColor(
                      Theme.of(context).colorScheme.onSurfaceVariant
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
