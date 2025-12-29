import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/providers/playback_provider.dart';
import 'package:rhapsody/providers/library_provider.dart';
import 'package:rhapsody/theme.dart';

class TrackListItem extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;
  final bool showAlbumArt;
  final bool showMoreButton;
  final Widget? trailing;

  const TrackListItem({
    super.key,
    required this.track,
    this.onTap,
    this.showAlbumArt = true,
    this.showMoreButton = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackProvider>();
    final library = context.watch<LibraryProvider>();
    final isCurrentTrack = playback.currentTrack?.id == track.id;
    final isLiked = library.isLiked(track.id);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.horizontalMd.add(AppSpacing.verticalSm),
        child: Row(
          children: [
            if (showAlbumArt) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: track.albumCoverUrl != null && track.albumCoverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: track.album!.getCoverUrl(size: 160),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 48,
                        height: 48,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 48,
                        height: 48,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isCurrentTrack ? Theme.of(context).colorScheme.primary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artistNames,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showMoreButton) ...[
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () => library.toggleLike(track.id),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
                onPressed: () => _showTrackOptions(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTrackOptions(BuildContext context) {
    final playback = context.read<PlaybackProvider>();
    final library = context.read<LibraryProvider>();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                children: [
                  if (track.albumCoverUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: CachedNetworkImage(
                        imageUrl: track.album!.getCoverUrl(size: 160),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(track.title, style: context.textStyles.bodyLarge?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(track.artistNames, style: context.textStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.playlist_add, color: Theme.of(context).colorScheme.onSurface),
              title: const Text('Add to queue'),
              onTap: () {
                playback.addToQueue(track);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to queue')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_play, color: Theme.of(context).colorScheme.onSurface),
              title: const Text('Play next'),
              onTap: () {
                playback.addNextInQueue(track);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Will play next')),
                );
              },
            ),
            ListTile(
              leading: Icon(
                library.isLiked(track.id) ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: Text(library.isLiked(track.id) ? 'Remove from liked songs' : 'Add to liked songs'),
              onTap: () {
                library.toggleLike(track.id);
                Navigator.pop(context);
              },
            ),
            if (library.playlists.isNotEmpty) ...[
              const Divider(height: 1),
              ...library.playlists.map((playlist) => ListTile(
                leading: Icon(Icons.playlist_add, color: Theme.of(context).colorScheme.onSurface),
                title: Text('Add to ${playlist.name}'),
                onTap: () {
                  library.addTrackToPlaylist(playlist.id, track.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to ${playlist.name}')),
                  );
                },
              )),
            ],
          ],
        ),
      ),
    );
  }
}
