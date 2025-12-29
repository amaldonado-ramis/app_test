import 'package:echostream/screens/album_detail_screen.dart';
import 'package:echostream/screens/api_playlist_screen.dart';
import 'package:echostream/screens/artist_detail_screen.dart';
import 'package:echostream/screens/liked_songs_screen.dart';
import 'package:echostream/screens/main_shell.dart';
import 'package:echostream/screens/now_playing_screen.dart';
import 'package:echostream/screens/user_playlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(),
        ),
      ),
      GoRoute(
        path: AppRoutes.nowPlaying,
        name: 'now-playing',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const NowPlayingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '${AppRoutes.album}/:id',
        name: 'album',
        pageBuilder: (context, state) => MaterialPage(
          child: AlbumDetailScreen(albumId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.artist}/:id',
        name: 'artist',
        pageBuilder: (context, state) => MaterialPage(
          child: ArtistDetailScreen(artistId: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: AppRoutes.likedSongs,
        name: 'liked-songs',
        pageBuilder: (context, state) => const MaterialPage(
          child: LikedSongsScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.playlist}/:id',
        name: 'playlist',
        pageBuilder: (context, state) => MaterialPage(
          child: UserPlaylistScreen(playlistId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.apiPlaylist}/:id',
        name: 'api-playlist',
        pageBuilder: (context, state) => MaterialPage(
          child: ApiPlaylistScreen(playlistId: state.pathParameters['id']!),
        ),
      ),
    ],
  );
}

class AppRoutes {
  static const String home = '/';
  static const String nowPlaying = '/now-playing';
  static const String album = '/album';
  static const String artist = '/artist';
  static const String likedSongs = '/liked-songs';
  static const String playlist = '/playlist';
  static const String apiPlaylist = '/api-playlist';
}
