import 'package:cached_network_image/cached_network_image.dart';
import 'package:echostream/providers/playback_provider.dart';
import 'package:echostream/services/artist_service.dart';
import 'package:echostream/widgets/album_card.dart';
import 'package:echostream/widgets/empty_state.dart';
import 'package:echostream/widgets/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArtistDetailScreen extends StatefulWidget {
  final int artistId;

  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> with SingleTickerProviderStateMixin {
  final ArtistService _artistService = ArtistService();
  ArtistDetails? _artistDetails;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadArtist();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadArtist() async {
    setState(() => _isLoading = true);
    
    final details = await _artistService.getArtistDetails(widget.artistId);
    
    setState(() {
      _artistDetails = details;
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

    if (_artistDetails == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.error, message: 'Failed to load artist'),
      );
    }

    final artist = _artistDetails!.artist;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: artist.getPictureUrl().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: artist.getPictureUrl(),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.person, size: 120, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                artist.name,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'Top Tracks'),
                Tab(text: 'Albums'),
                Tab(text: 'Singles & EPs'),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTopTracks(),
                _buildAlbums(),
                _buildEPs(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTracks() {
    final tracks = _artistDetails!.topTracks;
    
    if (tracks.isEmpty) {
      return const EmptyState(icon: Icons.music_note, message: 'No top tracks found');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: tracks.length,
      itemBuilder: (context, index) => TrackListTile(
        track: tracks[index],
        onTap: () => _playTrack(index),
      ),
    );
  }

  Widget _buildAlbums() {
    final albums = _artistDetails!.albums;
    
    if (albums.isEmpty) {
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
      itemCount: albums.length,
      itemBuilder: (context, index) => AlbumCard(album: albums[index]),
    );
  }

  Widget _buildEPs() {
    final eps = _artistDetails!.eps;
    
    if (eps.isEmpty) {
      return const EmptyState(icon: Icons.album, message: 'No EPs or singles found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: eps.length,
      itemBuilder: (context, index) => AlbumCard(album: eps[index]),
    );
  }

  void _playTrack(int index) {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_artistDetails!.topTracks, startIndex: index);
  }
}
