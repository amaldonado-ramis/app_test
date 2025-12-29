import 'package:echostream/providers/playback_provider.dart';
import 'package:echostream/services/playlist_api_service.dart';
import 'package:echostream/widgets/empty_state.dart';
import 'package:echostream/widgets/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApiPlaylistScreen extends StatefulWidget {
  final String playlistId;

  const ApiPlaylistScreen({super.key, required this.playlistId});

  @override
  State<ApiPlaylistScreen> createState() => _ApiPlaylistScreenState();
}

class _ApiPlaylistScreenState extends State<ApiPlaylistScreen> {
  final PlaylistApiService _playlistService = PlaylistApiService();
  PlaylistDetails? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    setState(() => _isLoading = true);
    
    final details = await _playlistService.getPlaylistDetails(widget.playlistId);
    
    setState(() {
      _details = details;
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

    if (_details == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.error, message: 'Failed to load playlist'),
      );
    }

    final playlist = _details!.playlist;
    final tracks = _details!.tracks;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(playlist.title),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                ),
                child: Icon(Icons.playlist_play, size: 80, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3)),
              ),
            ),
          ),
          if (tracks.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(icon: Icons.music_note, message: 'No tracks found'),
            )
          else
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () => _playAll(),
                          icon: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.onPrimary),
                          label: Text('Play All', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _shuffleAll(),
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Shuffle'),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tracks.length,
                    itemBuilder: (context, index) => TrackListTile(
                      track: tracks[index],
                      onTap: () => _playTrack(index),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _playAll() {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_details!.tracks, startIndex: 0);
  }

  void _shuffleAll() {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_details!.tracks, startIndex: 0);
    playbackProvider.toggleShuffle();
  }

  void _playTrack(int index) {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_details!.tracks, startIndex: index);
  }
}
