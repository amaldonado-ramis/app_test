import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echobeat/providers/library_provider.dart';
import 'package:echobeat/theme.dart';
import 'package:echobeat/components/track_tile.dart';

class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final likedTracks = libraryProvider.getLikedTracks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Songs'),
      ),
      body: likedTracks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No liked songs yet',
                    style: context.textStyles.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap the heart icon on any track to save it here',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: AppSpacing.paddingMd,
              itemCount: likedTracks.length,
              itemBuilder: (context, index) {
                return TrackTile(
                  track: likedTracks[index],
                  playlist: likedTracks,
                );
              },
            ),
    );
  }
}
