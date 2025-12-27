import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:echobeat/screens/home_screen.dart';
import 'package:echobeat/screens/search_results_screen.dart';
import 'package:echobeat/screens/liked_songs_screen.dart';
import 'package:echobeat/screens/playlists_screen.dart';
import 'package:echobeat/screens/playlist_detail_screen.dart';
import 'package:echobeat/screens/now_playing_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.searchResults,
        name: 'search-results',
        pageBuilder: (context, state) => const MaterialPage(
          child: SearchResultsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.liked,
        name: 'liked',
        pageBuilder: (context, state) => const MaterialPage(
          child: LikedSongsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.playlists,
        name: 'playlists',
        pageBuilder: (context, state) => const MaterialPage(
          child: PlaylistsScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.playlist}/:id',
        name: 'playlist-detail',
        pageBuilder: (context, state) => MaterialPage(
          child: PlaylistDetailScreen(
            playlistId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.nowPlaying,
        name: 'now-playing',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: NowPlayingScreen(),
        ),
      ),
    ],
  );
}

class AppRoutes {
  static const String home = '/';
  static const String searchResults = '/search-results';
  static const String liked = '/liked';
  static const String playlists = '/playlists';
  static const String playlist = '/playlist';
  static const String nowPlaying = '/now-playing';
}
