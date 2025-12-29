import 'package:echostream/models/track.dart';
import 'package:echostream/providers/playback_provider.dart';
import 'package:echostream/providers/user_playlist_provider.dart';
import 'package:echostream/services/track_service.dart';
import 'package:echostream/widgets/empty_state.dart';
import 'package:echostream/widgets/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserPlaylistScreen extends StatefulWidget {
  final String playlistId;

  const UserPlaylistScreen({super.key, required this.playlistId});

  @override
  State<UserPlaylistScreen> createState() => _UserPlaylistScreenState();
}

class _UserPlaylistScreenState extends State<UserPlaylistScreen> {
  final TrackService _trackService = TrackService();
  List<Track> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    setState(() => _isLoading = true);
    
    final playlistProvider = context.read<UserPlaylistProvider>();
    final playlist = playlistProvider.getPlaylist(widget.playlistId);
    
    if (playlist == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    final tracks = <Track>[];
    for (final id in playlist.trackIds) {
      final track = await _trackService.getTrackMetadata(id);
      if (track != null) {
        tracks.add(track);
      }
    }
    
    setState(() {
      _tracks = tracks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<UserPlaylistProvider>();
    final playlist = playlistProvider.getPlaylist(widget.playlistId);

    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.error, message: 'Playlist not found'),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(playlist.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Icon(Icons.playlist_play, size: 80, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3)),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showRenameDialog(playlist.name),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteDialog(),
              ),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_tracks.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.playlist_play,
                message: 'No tracks in this playlist\nAdd tracks from the track menu',
              ),
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
                    itemCount: _tracks.length,
                    itemBuilder: (context, index) => TrackListTile(
                      track: _tracks[index],
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

  void _showRenameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<UserPlaylistProvider>().renamePlaylist(widget.playlistId, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: const Text('Are you sure you want to delete this playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<UserPlaylistProvider>().deletePlaylist(widget.playlistId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          ),
        ],
      ),
    );
  }

  void _playAll() {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_tracks, startIndex: 0);
  }

  void _shuffleAll() {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_tracks, startIndex: 0);
    playbackProvider.toggleShuffle();
  }

  void _playTrack(int index) {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_tracks, startIndex: index);
  }
}
