import 'package:cached_network_image/cached_network_image.dart';
import 'package:echostream/providers/playback_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playbackProvider = context.watch<PlaybackProvider>();
    final currentTrack = playbackProvider.currentTrack;

    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    // Modern floating design
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GestureDetector(
        onTap: () => context.push('/now-playing'),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background progress indicator (optional, maybe too subtle)
                // Let's use a linear progress indicator at the bottom instead
                
                Row(
                  children: [
                    // Album Art
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Hero(
                        tag: 'mini_player_art_${currentTrack.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: currentTrack.albumCoverUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: currentTrack.albumCoverUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: Theme.of(context).colorScheme.surface,
                                    child: const Icon(Icons.music_note),
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                        ),
                      ),
                    ),
                    
                    // Title & Artist
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.title,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentTrack.artistName,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreamBuilder<bool>(
                          stream: playbackProvider.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 32,
                              ),
                              onPressed: playbackProvider.togglePlayPause,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 32,
                          ),
                          onPressed: playbackProvider.hasNext ? playbackProvider.next : null,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                
                // Progress Bar at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: StreamBuilder<Duration>(
                    stream: playbackProvider.positionStream,
                    builder: (context, positionSnapshot) {
                      return StreamBuilder<Duration?>(
                        stream: playbackProvider.durationStream,
                        builder: (context, durationSnapshot) {
                          final position = positionSnapshot.data ?? Duration.zero;
                          final duration = durationSnapshot.data ?? Duration.zero;
                          final progress = duration.inSeconds > 0 
                              ? position.inSeconds / duration.inSeconds 
                              : 0.0;
                          
                          if (progress <= 0) return const SizedBox.shrink();

                          return LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 2,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
