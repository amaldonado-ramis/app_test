import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/models/album.dart';
import 'package:rhapsody/models/artist.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/api/track_api.dart';
import 'package:rhapsody/services/api/album_api.dart';
import 'package:rhapsody/services/api/artist_api.dart';
import 'package:rhapsody/providers/playback_provider.dart';
import 'package:rhapsody/widgets/track_list_item.dart';
import 'package:rhapsody/widgets/album_card.dart';
import 'package:rhapsody/widgets/artist_card.dart';
import 'package:rhapsody/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _apiClient = TidalApiClient();
  late final TrackApi _trackApi;
  late final AlbumApi _albumApi;
  late final ArtistApi _artistApi;
  late final TabController _tabController;
  
  Timer? _debounceTimer;
  bool _isLoading = false;
  String _currentQuery = '';
  
  List<Track> _tracks = [];
  List<Album> _albums = [];
  List<Artist> _artists = [];

  @override
  void initState() {
    super.initState();
    _trackApi = TrackApi(_apiClient);
    _albumApi = AlbumApi(_apiClient);
    _artistApi = ArtistApi(_apiClient, _albumApi);
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounceTimer?.cancel();
    _apiClient.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty && query != _currentQuery) {
        _performSearch(query);
      } else if (query.isEmpty) {
        setState(() {
          _tracks = [];
          _albums = [];
          _artists = [];
          _currentQuery = '';
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _currentQuery = query;
    });

    final results = await Future.wait([
      _trackApi.searchTracks(query),
      _albumApi.searchAlbums(query),
      _artistApi.searchArtists(query),
    ]);

    if (mounted && _currentQuery == query) {
      setState(() {
        _tracks = results[0] as List<Track>;
        _albums = results[1] as List<Album>;
        _artists = results[2] as List<Artist>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showResults = _currentQuery.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.paddingMd,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for songs, albums, or artists',
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _tracks = [];
                            _albums = [];
                            _artists = [];
                            _currentQuery = '';
                          });
                        },
                      )
                    : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: AppSpacing.horizontalMd.add(AppSpacing.verticalMd),
                ),
                autofocus: false,
              ),
            ),
            if (showResults) ...[
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'Tracks'),
                  Tab(text: 'Albums'),
                  Tab(text: 'Artists'),
                ],
              ),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTracksTab(),
                        _buildAlbumsTab(),
                        _buildArtistsTab(),
                      ],
                    ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Search for music',
                        style: context.textStyles.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTracksTab() {
    if (_tracks.isEmpty) {
      return Center(
        child: Text(
          'No tracks found',
          style: context.textStyles.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        final track = _tracks[index];
        return TrackListItem(
          track: track,
          onTap: () {
            final playback = context.read<PlaybackProvider>();
            playback.playQueue(_tracks, startIndex: index);
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    if (_albums.isEmpty) {
      return Center(
        child: Text(
          'No albums found',
          style: context.textStyles.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: AppSpacing.paddingMd,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        final album = _albums[index];
        return AlbumCard(
          album: album,
          onTap: () => context.pushNamed(
            'search_album',
            pathParameters: {'id': album.id.toString()},
          ),
        );
      },
    );
  }

  Widget _buildArtistsTab() {
    if (_artists.isEmpty) {
      return Center(
        child: Text(
          'No artists found',
          style: context.textStyles.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: AppSpacing.paddingMd,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: _artists.length,
      itemBuilder: (context, index) {
        final artist = _artists[index];
        return ArtistCard(
          artist: artist,
          onTap: () => context.pushNamed(
            'search_artist',
            pathParameters: {'id': artist.id.toString()},
          ),
        );
      },
    );
  }
}
