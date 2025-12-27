import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:echobeat/models/track.dart';
import 'package:echobeat/models/album.dart';
import 'package:echobeat/services/api_service.dart';
import 'package:echobeat/providers/library_provider.dart';
import 'package:echobeat/theme.dart';
import 'package:echobeat/components/track_tile.dart';
import 'package:echobeat/components/album_card.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _searchController = TextEditingController();
  final _apiService = ApiService();
  Timer? _debounce;
  
  List<Track> _tracks = [];
  List<Album> _albums = [];
  bool _isLoading = false;
  String? _error;
  int _selectedTab = 0;
  int _tracksOffset = 0;
  int _albumsOffset = 0;
  bool _hasMoreTracks = false;
  bool _hasMoreAlbums = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _apiService.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _tracks = [];
        _albums = [];
        _error = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query, isNewSearch: true);
    });
  }

  Future<void> _performSearch(String query, {bool isNewSearch = false}) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      if (isNewSearch) {
        _tracks = [];
        _albums = [];
        _tracksOffset = 0;
        _albumsOffset = 0;
      }
    });

    try {
      if (_selectedTab == 0) {
        final result = await _apiService.searchTracks(
          query,
          offset: isNewSearch ? 0 : _tracksOffset,
        );
        
        if (mounted) {
          setState(() {
            if (isNewSearch) {
              _tracks = result.tracks;
            } else {
              _tracks.addAll(result.tracks);
            }
            _tracksOffset += result.pagination.returned;
            _hasMoreTracks = result.pagination.hasMore;
          });
          
          context.read<LibraryProvider>().cacheTracks(result.tracks);
        }
      } else {
        final result = await _apiService.searchAlbums(
          query,
          offset: isNewSearch ? 0 : _albumsOffset,
        );
        
        if (mounted) {
          setState(() {
            if (isNewSearch) {
              _albums = result.albums;
            } else {
              _albums.addAll(result.albums);
            }
            _albumsOffset += result.pagination.returned;
            _hasMoreAlbums = result.pagination.hasMore;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Search failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadMore() {
    if (!_isLoading && _searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search tracks or albums...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onChanged: _onSearchChanged,
          autofocus: true,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: TabController(
              length: 2,
              vsync: Navigator.of(context),
              initialIndex: _selectedTab,
            ),
            onTap: (index) {
              setState(() {
                _selectedTab = index;
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text, isNewSearch: true);
                }
              });
            },
            tabs: const [
              Tab(text: 'Tracks'),
              Tab(text: 'Albums'),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Start typing to search',
              style: context.textStyles.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading && (_tracks.isEmpty && _albums.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
              _error!,
              style: context.textStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => _performSearch(_searchController.text, isNewSearch: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_selectedTab == 0) {
      if (_tracks.isEmpty) {
        return const Center(child: Text('No tracks found'));
      }
      
      return ListView.builder(
        padding: AppSpacing.paddingMd,
        itemCount: _tracks.length + (_hasMoreTracks ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _tracks.length) {
            if (!_isLoading) _loadMore();
            return const Padding(
              padding: AppSpacing.paddingLg,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          return TrackTile(
            track: _tracks[index],
            playlist: _tracks,
          );
        },
      );
    } else {
      if (_albums.isEmpty) {
        return const Center(child: Text('No albums found'));
      }
      
      return GridView.builder(
        padding: AppSpacing.paddingMd,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: _albums.length + (_hasMoreAlbums ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _albums.length) {
            if (!_isLoading) _loadMore();
            return const Center(child: CircularProgressIndicator());
          }
          
          return AlbumCard(
            album: _albums[index],
            onTap: () => context.push('/album/${_albums[index].id}'),
          );
        },
      );
    }
  }
}
