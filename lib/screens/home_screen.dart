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
            title: Text(
              'EchoStream',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
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
          else
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Popular Tracks',
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _popularTracks.length,
                    itemBuilder: (context, index) {
                      final track = _popularTracks[index];
                      return TrackListTile(
                        track: track,
                        onTap: () => _playTrack(index),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _playTrack(int index) {
    final playbackProvider = context.read<PlaybackProvider>();
    playbackProvider.setQueue(_popularTracks, startIndex: index);
  }
}
