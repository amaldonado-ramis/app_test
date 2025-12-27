import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echobeat/models/track.dart';
import 'package:echobeat/providers/playback_provider.dart';
import 'package:echobeat/providers/library_provider.dart';
import 'package:echobeat/theme.dart';
import 'package:echobeat/components/add_to_playlist_dialog.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final List<Track>? playlist;
  final VoidCallback? onTap;
  final bool showAlbumArt;

  const TrackTile({
    super.key,
    required this.track,
    this.playlist,
    this.onTap,
    this.showAlbumArt = true,
  });

  @override
  Widget build(BuildContext context) {
    final playbackProvider = context.watch<PlaybackProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    final isCurrentTrack = playbackProvider.currentTrack?.id == track.id;
    final isLiked = libraryProvider.isLiked(track.id);

    return InkWell(
      onTap: onTap ?? () {
        playbackProvider.playTrack(track, playlist: playlist);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: AppSpacing.paddingSm,
        child: Row(
          children: [
            if (showAlbumArt) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                clipBehavior: Clip.antiAlias,
                child: track.coverUrl.isNotEmpty
                    ? Image.network(
                        track.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.music_note,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(
                        Icons.music_note,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: context.textStyles.titleMedium?.copyWith(
                      color: isCurrentTrack
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isCurrentTrack ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isCurrentTrack && playbackProvider.isPlaying)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  Icons.graphic_eq,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            Text(
              track.formattedDuration,
              style: context.textStyles.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Theme.of(context).colorScheme.secondary : null,
              ),
              onPressed: () => libraryProvider.toggleLike(track),
            ),
            IconButton(
              icon: const Icon(Icons.playlist_add),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AddToPlaylistDialog(track: track),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
