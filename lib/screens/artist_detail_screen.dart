import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:rhapsody/models/artist.dart';
import 'package:rhapsody/models/album.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/api/artist_api.dart';
import 'package:rhapsody/services/api/album_api.dart';
import 'package:rhapsody/providers/playback_provider.dart';
import 'package:rhapsody/widgets/track_list_item.dart';
import 'package:rhapsody/widgets/album_card.dart';
import 'package:rhapsody/theme.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistId;

  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  final _apiClient = TidalApiClient();
  late final ArtistApi _artistApi;
  
  bool _isLoading = true;
  Artist? _artist;
  List<Track> _topTracks = [];
  List<Album> _albums = [];
  List<Album> _eps = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    final albumApi = AlbumApi(_apiClient);
    _artistApi = ArtistApi(_apiClient, albumApi);
    _loadArtistDetails();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _loadArtistDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final artistId = int.tryParse(widget.artistId);
      if (artistId == null) {
        setState(() {
          _error = 'Invalid artist ID';
          _isLoading = false;
        });
        return;
      }

      final page = await _artistApi.getArtistPage(artistId);
      if (page != null && mounted) {
        setState(() {
          _artist = page.artist;
          _topTracks = page.topTracks;
          _albums = page.albums;
          _eps = page.eps;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _error = 'Could not load artist details';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading artist: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        extendBodyBehindAppBar: true,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _artist == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        extendBodyBehindAppBar: true,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: AppSpacing.md),
              Text(_error ?? 'Artist not found', style: context.textStyles.bodyLarge),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _loadArtistDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          if (_topTracks.isNotEmpty) _buildTopTracksSection(context),
          if (_albums.isNotEmpty) _buildHorizontalSection(context, 'Albums', _albums),
          if (_eps.isNotEmpty) _buildHorizontalSection(context, 'Singles & EPs', _eps),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_artist!.picture != null)
              CachedNetworkImage(
                imageUrl: _artist!.getPictureUrl(size: 750),
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              )
            else
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(Icons.person, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            
            // Gradient Overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.0),
                    Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _artist!.name,
                    style: context.textStyles.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 10,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_topTracks.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () {
                        context.read<PlaybackProvider>().playQueue(_topTracks);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play Popular'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTracksSection(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Popular', style: context.textStyles.titleLarge?.bold),
              );
            }
            final track = _topTracks[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$index',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TrackListItem(
                      track: track,
                      showAlbumArt: true,
                      onTap: () {
                        context.read<PlaybackProvider>().playQueue(_topTracks, startIndex: index - 1);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: (_topTracks.length > 5 ? 5 : _topTracks.length) + 1,
        ),
      ),
    );
  }

  Widget _buildHorizontalSection(BuildContext context, String title, List<Album> items) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: context.textStyles.titleLarge?.bold),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final album = items[index];
                return SizedBox(
                  width: 150,
                  child: AlbumCard(
                    album: album,
                    size: 150,
                    onTap: () {
                      final location = GoRouterState.of(context).uri.toString();
                      if (location.startsWith('/search')) {
                        context.pushNamed('search_album', pathParameters: {'id': album.id.toString()});
                      } else if (location.startsWith('/library')) {
                        context.pushNamed('library_album', pathParameters: {'id': album.id.toString()});
                      } else {
                        context.pushNamed('home_album', pathParameters: {'id': album.id.toString()});
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
