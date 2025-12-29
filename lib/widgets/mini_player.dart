import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:rhapsody/providers/playback_provider.dart';
import 'package:rhapsody/providers/library_provider.dart';
import 'package:rhapsody/theme.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackProvider>();
    final library = context.watch<LibraryProvider>();
    final currentTrack = playback.currentTrack;

    if (currentTrack == null) return const SizedBox.shrink();

    final progress = playback.playbackState?.progress ?? 0.0;
    final isLiked = library.isLiked(currentTrack.id);

    return Positioned(
      bottom: AppSpacing.md, // Floating above bottom
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: GestureDetector(
        onTap: () => context.push('/player'),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm - 2),
                          child: currentTrack.albumCoverUrl != null && currentTrack.albumCoverUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: currentTrack.album!.getCoverUrl(size: 160),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                color: Theme.of(context).colorScheme.surface,
                                child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTrack.title,
                                style: context.textStyles.bodyMedium?.semiBold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentTrack.artistNames,
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                          onPressed: () => library.toggleLike(currentTrack.id),
                        ),
                        IconButton(
                          icon: Icon(
                            playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 32,
                          ),
                          onPressed: () => playback.togglePlayPause(),
                        ),
                      ],
                    ),
                  ),
                ),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
