import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/providers/library_provider.dart';
import 'package:rhapsody/providers/playback_provider.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/api/track_api.dart';
import 'package:rhapsody/theme.dart';
import 'package:rhapsody/widgets/track_list_item.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final _apiClient = TidalApiClient();
  late final TrackApi _trackApi;
  
  bool _isLoading = true;
  List<Track> _tracks = [];
  String _title = '';
  String _subtitle = '';
  Color _headerColor = Colors.grey;
  IconData _headerIcon = Icons.playlist_play;
  
  @override
  void initState() {
    super.initState();
    _trackApi = TrackApi(_apiClient);
    _loadPlaylist();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylist() async {
    setState(() => _isLoading = true);

    final library = context.read<LibraryProvider>();
    List<int> trackIds = [];

    if (widget.playlistId == 'liked') {
      _title = 'Liked Songs';
      _headerColor = Colors.pink;
      _headerIcon = Icons.favorite;
      trackIds = library.likedSongIds.toList();
    } else {
      final playlist = library.getPlaylist(widget.playlistId);
      if (playlist == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist not found')),
          );
          context.pop();
        }
        return;
      }
      _title = playlist.name;
      _headerColor = Colors.orange;
      _headerIcon = Icons.playlist_play;
      trackIds = playlist.trackIds;
    }

    _subtitle = '${trackIds.length} songs';

    try {
      if (trackIds.isEmpty) {
        setState(() {
          _tracks = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch tracks in parallel
      final futures = trackIds.map((id) => _trackApi.getTrack(id));
      final results = await Future.wait(futures);
      
      if (mounted) {
        setState(() {
          _tracks = results.whereType<Track>().toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tracks: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_title),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _headerColor,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _headerIcon,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            actions: [
              if (widget.playlistId != 'liked')
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Playlist',
                  onPressed: () => _confirmDeletePlaylist(context),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                children: [
                  Text(
                    _subtitle,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (_tracks.isNotEmpty) ...[
                    IconButton.filled(
                      onPressed: () {
                        final playback = context.read<PlaybackProvider>();
                        playback.playQueue(_tracks);
                      },
                      icon: const Icon(Icons.play_arrow),
                      iconSize: 32,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    IconButton.outlined(
                      onPressed: () {
                        final playback = context.read<PlaybackProvider>();
                        playback.queueManager.toggleShuffle();
                        playback.playQueue(_tracks);
                      },
                      icon: const Icon(Icons.shuffle),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_tracks.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = _tracks[index];
                  return Dismissible(
                    key: Key('playlist_track_${widget.playlistId}_${track.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Theme.of(context).colorScheme.error,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (widget.playlistId == 'liked') {
                        // For liked songs, removing means unliking
                        // We'll let the user use the heart icon instead for now to prevent accidental swipes
                        // Or we can implement it. Let's implementing it.
                        return true;
                      } else {
                        // For user playlists, remove from playlist
                        return true;
                      }
                    },
                    onDismissed: (direction) {
                      final library = context.read<LibraryProvider>();
                      if (widget.playlistId == 'liked') {
                        library.toggleLike(track.id);
                      } else {
                        library.removeTrackFromPlaylist(widget.playlistId, track.id);
                      }
                      
                      setState(() {
                        _tracks.removeAt(index);
                        _subtitle = '${_tracks.length} songs';
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Removed from playlist')),
                      );
                    },
                    child: TrackListItem(
                      track: track,
                      showAlbumArt: true,
                      onTap: () {
                        final playback = context.read<PlaybackProvider>();
                        playback.playQueue(_tracks, startIndex: index);
                      },
                      trailing: widget.playlistId != 'liked' 
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                               final library = context.read<LibraryProvider>();
                               library.removeTrackFromPlaylist(widget.playlistId, track.id);
                               setState(() {
                                 _tracks.removeAt(index);
                                 _subtitle = '${_tracks.length} songs';
                               });
                            },
                          )
                        : null,
                    ),
                  );
                },
                childCount: _tracks.length,
              ),
            )
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No songs yet',
                      style: context.textStyles.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDeletePlaylist(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "$_title"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<LibraryProvider>().deletePlaylist(widget.playlistId);
              context.pop(); // Close dialog
              context.pop(); // Go back to library
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
