import 'package:cached_network_image/cached_network_image.dart';
import 'package:echostream/models/track.dart';
import 'package:echostream/providers/liked_songs_provider.dart';
import 'package:echostream/providers/playback_provider.dart';
import 'package:echostream/providers/user_playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrackListTile extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;
  final bool showAlbumArt;
  final bool showMenu;

  const TrackListTile({
    super.key,
    required this.track,
    this.onTap,
    this.showAlbumArt = true,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    final likedProvider = context.watch<LikedSongsProvider>();
    final playbackProvider = context.watch<PlaybackProvider>();
    final isLiked = likedProvider.isLiked(track.id);
    final isPlaying = playbackProvider.currentTrack?.id == track.id;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (showAlbumArt) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: track.albumCoverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: track.albumCoverUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 56,
                          height: 56,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 56,
                          height: 56,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
                      color: isPlaying ? Theme.of(context).colorScheme.primary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artistName,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              track.formatDuration(),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () => likedProvider.toggleLike(track.id),
            ),
            if (showMenu)
              IconButton(
                icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
                onPressed: () => _showTrackMenu(context),
              ),
          ],
        ),
      ),
    );
  }

  void _showTrackMenu(BuildContext context) {
    final playlistProvider = context.read<UserPlaylistProvider>();
    final playbackProvider = context.read<PlaybackProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: track.albumCoverUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: track.albumCoverUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.music_note),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(track.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(track.artistName, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.queue_music, color: Theme.of(context).colorScheme.primary),
              title: const Text('Add to queue'),
              onTap: () {
                playbackProvider.addToQueue(track);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to queue'), duration: Duration(seconds: 1)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_add, color: Theme.of(context).colorScheme.primary),
              title: const Text('Add to playlist'),
              onTap: () {
                Navigator.pop(context);
                _showPlaylistSelector(context, playlistProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistSelector(BuildContext context, UserPlaylistProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Add to Playlist', style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(height: 1),
            if (provider.playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No playlists yet', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              )
            else
              ...provider.playlists.map((playlist) => ListTile(
                leading: Icon(Icons.playlist_play, color: Theme.of(context).colorScheme.primary),
                title: Text(playlist.name),
                subtitle: Text('${playlist.trackIds.length} tracks'),
                onTap: () {
                  provider.addTrackToPlaylist(playlist.id, track.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to ${playlist.name}'), duration: const Duration(seconds: 1)),
                  );
                },
              )),
          ],
        ),
      ),
    );
  }
}
