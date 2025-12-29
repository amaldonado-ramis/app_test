import 'dart:async';
import 'package:echostream/models/album.dart';
import 'package:echostream/models/artist.dart';
import 'package:echostream/models/playlist_preview.dart';
import 'package:echostream/models/track.dart';
import 'package:echostream/providers/playback_provider.dart';
import 'package:echostream/services/search_service.dart';
import 'package:echostream/widgets/album_card.dart';
import 'package:echostream/widgets/artist_card.dart';
import 'package:echostream/widgets/empty_state.dart';
import 'package:echostream/widgets/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  Timer? _debounce;

  List<Track> _tracks = [];
  List<Album> _albums = [];
  List<Artist> _artists = [];
  List<PlaylistPreview> _playlists = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _tracks = [];
        _albums = [];
        _artists = [];
        _playlists = [];
        _hasSearched = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);

    final results = await Future.wait([
      _searchService.searchTracks(query),
      _searchService.searchAlbums(query),
      _searchService.searchArtists(query),
      _searchService.searchPlaylists(query),
    ]);

    setState(() {
      _tracks = results[0] as List<Track>;
      _albums = results[1] as List<Album>;
      _artists = results[2] as List<Artist>;
      _playlists = results[3] as List<PlaylistPreview>;
      _isSearching = false;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search songs, albums, artists...',
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_hasSearched) ...[
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'Tracks'),
                  Tab(text: 'Albums'),
                  Tab(text: 'Artists'),
                  Tab(text: 'Playlists'),
                ],
              ),
              Expanded(
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTracksList(),
                          _buildAlbumsList(),
                          _buildArtistsList(),
                          _buildPlaylistsList(),
                        ],
                      ),
              ),
            ] else
              const Expanded(
                child: EmptyState(
                  icon: Icons.search,
                  message: 'Search for your favorite music',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTracksList() {
    if (_tracks.isEmpty) {
      return const EmptyState(icon: Icons.music_note, message: 'No tracks found');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        return TrackListTile(
          track: _tracks[index],
          onTap: () => _playTrack(index),
        );
      },
    );
  }

  Widget _buildAlbumsList() {
    if (_albums.isEmpty) {
      return const EmptyState(icon: Icons.album, message: 'No albums found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _albums.length,
      itemBuilder: (context, index) => AlbumCard(album: _albums[index]),
    );
  }

  Widget _buildArtistsList() {
    if (_artists.isEmpty) {
      return const EmptyState(icon: Icons.person, message: 'No artists found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _artists.length,
      itemBuilder: (context, index) => ArtistCard(artist: _artists[index]),
    );
  }

  Widget _buildPlaylistsList() {
    if (_playlists.isEmpty) {
      return const EmptyState(icon: Icons.playlist_play, message: 'No playlists found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.playlist_play, color: Theme.of(context).colorScheme.primary, size: 32),
            ),
            title: Text(playlist.title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text('${playlist.numberOfTracks} tracks'),
            onTap: () => context.push('/api-playlist/${playlist.id}'),
          ),
        );
      },
    );
  }

  void _playTrack(int index) {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_tracks, startIndex: index);
  }
}
