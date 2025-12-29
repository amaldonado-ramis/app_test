import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rhapsody/providers/library_provider.dart';
import 'package:rhapsody/theme.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Your Library', style: context.textStyles.headlineMedium?.bold),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => _showCreatePlaylistDialog(context),
              ),
            ],
          ),
          SliverPadding(
            padding: AppSpacing.paddingMd,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  child: ListTile(
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white, size: 28),
                    ),
                    title: Text('Liked Songs', style: context.textStyles.bodyLarge?.semiBold),
                    subtitle: Text('${library.likedSongsCount} songs'),
                    trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onTap: () => context.push('playlist/liked'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (library.playlists.isNotEmpty) ...[
                  Text('Playlists', style: context.textStyles.titleMedium?.semiBold),
                  const SizedBox(height: AppSpacing.md),
                  ...library.playlists.map((playlist) => Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.playlist_play,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 28,
                        ),
                      ),
                      title: Text(playlist.name, style: context.textStyles.bodyLarge?.semiBold),
                      subtitle: Text('${playlist.trackCount} songs'),
                      trailing: PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('Rename'),
                            onTap: () => Future.delayed(
                              Duration.zero,
                              () => _showRenamePlaylistDialog(context, playlist.id, playlist.name),
                            ),
                          ),
                          PopupMenuItem(
                            child: const Text('Delete'),
                            onTap: () => Future.delayed(
                              Duration.zero,
                              () => _confirmDeletePlaylist(context, playlist.id, playlist.name),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => context.push('playlist/${playlist.id}'),
                    ),
                  )),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.library_music,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No playlists yet',
                            style: context.textStyles.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Create a playlist to organize your music',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<LibraryProvider>().createPlaylist(controller.text.trim());
                context.pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenamePlaylistDialog(BuildContext context, String playlistId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<LibraryProvider>().renamePlaylist(playlistId, controller.text.trim());
                context.pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlaylist(BuildContext context, String playlistId, String playlistName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "$playlistName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<LibraryProvider>().deletePlaylist(playlistId);
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
