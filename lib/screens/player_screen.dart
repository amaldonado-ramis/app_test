import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rhapsody/providers/playback_provider.dart';
import 'package:rhapsody/providers/library_provider.dart';
import 'package:rhapsody/services/playback/queue_manager.dart';
import 'package:rhapsody/theme.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackProvider>();
    final library = context.watch<LibraryProvider>();
    final currentTrack = playback.currentTrack;

    if (currentTrack == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No track playing')),
      );
    }

    final isLiked = library.isLiked(currentTrack.id);
    final progress = playback.playbackState?.progress ?? 0.0;
    final position = playback.playbackState?.position ?? Duration.zero;
    final duration = playback.playbackState?.duration ?? Duration.zero;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white),
            onPressed: () => _showQueueSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Blurred Background Image
          Positioned.fill(
            child: currentTrack.albumCoverUrl != null && currentTrack.albumCoverUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: currentTrack.album!.getCoverUrl(),
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: Colors.black),
                  )
                : Container(color: Colors.black),
          ),
          
          // 2. Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),

          // 3. Gradient Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),

          // 4. Content
          SafeArea(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  
                  // Album Art
                  Hero(
                    tag: 'player_album_art',
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: currentTrack.albumCoverUrl != null && currentTrack.albumCoverUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: currentTrack.album!.getCoverUrl(size: 640),
                              width: MediaQuery.of(context).size.width - 48,
                              height: MediaQuery.of(context).size.width - 48,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width - 48,
                              height: MediaQuery.of(context).size.width - 48,
                              color: Colors.grey[900],
                              child: const Icon(Icons.music_note, size: 80, color: Colors.white),
                            ),
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Title and Artist
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTrack.title,
                              style: context.textStyles.headlineSmall?.bold.withColor(Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              currentTrack.artistNames,
                              style: context.textStyles.titleMedium?.medium.withColor(Colors.white.withValues(alpha: 0.7)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Theme.of(context).colorScheme.primary : Colors.white,
                        ),
                        iconSize: 32,
                        onPressed: () => library.toggleLike(currentTrack.id),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Progress Bar
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            final newPosition = duration * value;
                            playback.seek(newPosition);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: context.textStyles.bodySmall?.withColor(Colors.white.withValues(alpha: 0.7)),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: context.textStyles.bodySmall?.withColor(Colors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          playback.shuffleEnabled ? Icons.shuffle_on : Icons.shuffle,
                          color: playback.shuffleEnabled
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        ),
                        iconSize: 24,
                        onPressed: () => playback.toggleShuffle(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                        iconSize: 42,
                        onPressed: playback.queueManager.hasPrevious ? () => playback.previous() : null,
                      ),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.black,
                          ),
                          iconSize: 40,
                          onPressed: () => playback.togglePlayPause(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                        iconSize: 42,
                        onPressed: playback.queueManager.hasNext ? () => playback.next() : null,
                      ),
                      IconButton(
                        icon: Icon(
                          _getRepeatIcon(playback.repeatMode),
                          color: playback.repeatMode != RepeatMode.off
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        ),
                        iconSize: 24,
                        onPressed: () => playback.cycleRepeatMode(),
                      ),
                    ],
                  ),
                  
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return Icons.repeat_rounded;
      case RepeatMode.all:
        return Icons.repeat_on_rounded;
      case RepeatMode.one:
        return Icons.repeat_one_on_rounded;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showQueueSheet(BuildContext context) {
    final playback = context.read<PlaybackProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: AppSpacing.horizontalMd.add(const EdgeInsets.only(bottom: AppSpacing.md)),
                  child: Text('Next Up', style: context.textStyles.titleLarge?.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: playback.queue.length,
                    itemBuilder: (context, index) {
                      final track = playback.queue[index];
                      final isCurrent = index == playback.currentIndex;
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: track.albumCoverUrl != null
                            ? CachedNetworkImage(
                                imageUrl: track.album!.getCoverUrl(size: 64),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : Container(width: 48, height: 48, color: Colors.grey),
                        ),
                        title: Text(
                          track.title,
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                            fontWeight: isCurrent ? FontWeight.bold : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          track.artistNames,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => playback.removeFromQueue(index),
                        ),
                        onTap: () {
                          playback.jumpToIndex(index);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
