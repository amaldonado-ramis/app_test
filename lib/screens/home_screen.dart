import 'package:echostream/models/track.dart';
import 'package:echostream/providers/playback_provider.dart';
import 'package:echostream/services/search_service.dart';
import 'package:echostream/widgets/empty_state.dart';
import 'package:echostream/widgets/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SearchService _searchService = SearchService();
  List<Track> _popularTracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPopularTracks();
  }

  Future<void> _loadPopularTracks() async {
    setState(() => _isLoading = true);
    
    // In a real app we might cache this or have a "Trending" endpoint
    final tracks = await _searchService.searchTracks('top hits');
    
    setState(() {
      _popularTracks = tracks.take(20).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120.0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Discover',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {}, // Future feature
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {}, // Future feature
              ),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_popularTracks.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.music_note,
                message: 'No tracks found',
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trending Now',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
                      onPressed: _loadPopularTracks,
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = _popularTracks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TrackListTile(
                      track: track,
                      onTap: () => _playTrack(index),
                    ),
                  );
                },
                childCount: _popularTracks.length,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ],
      ),
    );
  }

  void _playTrack(int index) {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_popularTracks, startIndex: index);
  }
}
