import 'package:cached_network_image/cached_network_image.dart';
import 'package:echostream/providers/liked_songs_provider.dart';
import 'package:echostream/providers/playback_provider.dart';
import 'package:echostream/services/playback_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playbackProvider = context.watch<PlaybackProvider>();
    final likedProvider = context.watch<LikedSongsProvider>();
    final currentTrack = playbackProvider.currentTrack;

    if (currentTrack == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('No track playing')),
      );
    }

    final isLiked = likedProvider.isLiked(currentTrack.id);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      'NOW PLAYING',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),

              // Album Art
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Hero(
                  tag: 'mini_player_art_${currentTrack.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: currentTrack.albumCoverUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: currentTrack.albumCoverUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: Icon(Icons.music_note, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              )
                            : Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.music_note, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Title and Artist + Like Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.title,
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentTrack.artistName,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isLiked ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 32,
                      ),
                      onPressed: () => likedProvider.toggleLike(currentTrack.id),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ProgressBar(),
              ),

              const SizedBox(height: 24),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        playbackProvider.isShuffled ? Icons.shuffle_on_outlined : Icons.shuffle_rounded,
                        color: playbackProvider.isShuffled 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: playbackProvider.toggleShuffle,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        size: 40,
                        color: playbackProvider.hasPrevious 
                          ? Theme.of(context).colorScheme.onSurface 
                          : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                      onPressed: playbackProvider.hasPrevious ? playbackProvider.previous : null,
                    ),
                    StreamBuilder<bool>(
                      stream: playbackProvider.playingStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 40,
                            ),
                            onPressed: playbackProvider.togglePlayPause,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next_rounded,
                        size: 40,
                        color: playbackProvider.hasNext 
                          ? Theme.of(context).colorScheme.onSurface 
                          : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                      onPressed: playbackProvider.hasNext ? playbackProvider.next : null,
                    ),
                    IconButton(
                      icon: Icon(
                        playbackProvider.repeatMode == RepeatMode.off
                            ? Icons.repeat_rounded
                            : playbackProvider.repeatMode == RepeatMode.all
                                ? Icons.repeat_on_outlined
                                : Icons.repeat_one_on_outlined,
                        color: playbackProvider.repeatMode != RepeatMode.off
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: playbackProvider.cycleRepeatMode,
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playbackProvider = context.watch<PlaybackProvider>();

    return StreamBuilder<Duration>(
      stream: playbackProvider.positionStream,
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration?>(
          stream: playbackProvider.durationStream,
          builder: (context, durationSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final duration = durationSnapshot.data ?? Duration.zero;
            final progress = duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    thumbColor: Theme.of(context).colorScheme.primary,
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (value) {
                      final newPosition = Duration(seconds: (value * duration.inSeconds).round());
                      playbackProvider.seek(newPosition);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
