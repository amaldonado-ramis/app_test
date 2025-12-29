import 'package:cached_network_image/cached_network_image.dart';
import 'package:echostream/providers/playback_provider.dart';
import 'package:echostream/services/album_service.dart';
import 'package:echostream/widgets/empty_state.dart';
import 'package:echostream/widgets/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumId;

  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final AlbumService _albumService = AlbumService();
  AlbumDetails? _albumDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbum();
  }

  Future<void> _loadAlbum() async {
    setState(() => _isLoading = true);
    
    final details = await _albumService.getAlbumDetails(widget.albumId);
    
    setState(() {
      _albumDetails = details;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_albumDetails == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.error, message: 'Failed to load album'),
      );
    }

    final album = _albumDetails!.album;
    final tracks = _albumDetails!.tracks;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: album.getCoverUrl().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: album.getCoverUrl(),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.album, size: 120, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (album.artist != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      album.artist!.name,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (album.releaseDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      album.releaseDate!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: tracks.isNotEmpty ? () => _playAlbum() : null,
                        icon: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.onPrimary),
                        label: Text('Play', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: tracks.isNotEmpty ? () => _shuffleAlbum() : null,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Shuffle'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (tracks.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(icon: Icons.music_note, message: 'No tracks found'),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TrackListTile(
                  track: tracks[index],
                  onTap: () => _playTrack(index),
                  showAlbumArt: false,
                ),
                childCount: tracks.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _playAlbum() {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_albumDetails!.tracks, startIndex: 0);
  }

  void _shuffleAlbum() {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_albumDetails!.tracks, startIndex: 0);
    playbackProvider.toggleShuffle();
  }

  void _playTrack(int index) {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_albumDetails!.tracks, startIndex: index);
  }
}
