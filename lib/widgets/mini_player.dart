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

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/now-playing'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: currentTrack.albumCoverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: currentTrack.albumCoverUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 56,
                            height: 56,
                            color: Theme.of(context).colorScheme.surface,
                            child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTrack.title,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentTrack.artistName,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  stream: playbackProvider.playingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      onPressed: playbackProvider.togglePlayPause,
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    color: playbackProvider.hasNext 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    size: 32,
                  ),
                  onPressed: playbackProvider.hasNext ? playbackProvider.next : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
