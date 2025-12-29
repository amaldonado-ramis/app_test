import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rhapsody/models/album.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/api/album_api.dart';
import 'package:rhapsody/providers/playback_provider.dart';
import 'package:rhapsody/widgets/track_list_item.dart';
import 'package:rhapsody/theme.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumId;

  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final _apiClient = TidalApiClient();
  late final AlbumApi _albumApi;
  
  bool _isLoading = true;
  Album? _album;
  List<Track> _tracks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _albumApi = AlbumApi(_apiClient);
    _loadAlbumDetails();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _loadAlbumDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final details = await _albumApi.getAlbumDetails(widget.albumId);
      if (details != null && mounted) {
        setState(() {
          _album = details.album;
          _tracks = details.tracks;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _error = 'Could not load album details';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading album: $e';
          _isLoading = false;
        });
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

    if (_error != null || _album == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _error ?? 'Album not found',
                style: context.textStyles.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_album!.cover != null && _album!.cover!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: _album!.getCoverUrl(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.album, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  else
                    Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.album, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_album!.title, style: context.textStyles.headlineMedium?.bold),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _album!.artistNames,
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_album!.releaseDate != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _album!.releaseDate!.split('-')[0],
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _tracks.isNotEmpty
                          ? () {
                              final playback = context.read<PlaybackProvider>();
                              playback.playQueue(_tracks);
                            }
                          : null,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: _tracks.isNotEmpty
                          ? () {
                              final playback = context.read<PlaybackProvider>();
                              playback.queueManager.toggleShuffle();
                              playback.playQueue(_tracks);
                            }
                          : null,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Shuffle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          if (_tracks.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = _tracks[index];
                  return TrackListItem(
                    track: track,
                    showAlbumArt: false,
                    onTap: () {
                      final playback = context.read<PlaybackProvider>();
                      playback.playQueue(_tracks, startIndex: index);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.durationFormatted,
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                    ),
                  );
                },
                childCount: _tracks.length,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Text(
                    'No tracks available',
                    style: context.textStyles.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
