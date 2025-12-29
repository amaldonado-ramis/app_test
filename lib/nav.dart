import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rhapsody/screens/main_scaffold.dart';
import 'package:rhapsody/screens/player_screen.dart';
import 'package:rhapsody/screens/album_detail_screen.dart';
import 'package:rhapsody/screens/artist_detail_screen.dart';
import 'package:rhapsody/screens/playlist_detail_screen.dart';
import 'package:rhapsody/screens/home_screen.dart';
import 'package:rhapsody/screens/search_screen.dart';
import 'package:rhapsody/screens/library_screen.dart';

// Global key for the root navigator to allow pushing screens on top of the bottom nav
final _rootNavigatorKey = GlobalKey<NavigatorState>();
// Global key for the shell navigator
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      // Stateful Nested Navigation (Bottom Bar)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'album/:id',
                    name: 'home_album',
                    builder: (context, state) => AlbumDetailScreen(
                      albumId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'artist/:id',
                    name: 'home_artist',
                    builder: (context, state) => ArtistDetailScreen(
                      artistId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'playlist/:id',
                    name: 'home_playlist',
                    builder: (context, state) => PlaylistDetailScreen(
                      playlistId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SearchScreen(),
                ),
                routes: [
                   GoRoute(
                    path: 'album/:id',
                    name: 'search_album',
                    builder: (context, state) => AlbumDetailScreen(
                      albumId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'artist/:id',
                    name: 'search_artist',
                    builder: (context, state) => ArtistDetailScreen(
                      artistId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'playlist/:id',
                    name: 'search_playlist',
                    builder: (context, state) => PlaylistDetailScreen(
                      playlistId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Library Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.library,
                name: 'library',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LibraryScreen(),
                ),
                routes: [
                   GoRoute(
                    path: 'album/:id',
                    name: 'library_album',
                    builder: (context, state) => AlbumDetailScreen(
                      albumId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'artist/:id',
                    name: 'library_artist',
                    builder: (context, state) => ArtistDetailScreen(
                      artistId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'playlist/:id',
                    name: 'library_playlist',
                    builder: (context, state) => PlaylistDetailScreen(
                      playlistId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Full screen player (on top of everything)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.player,
        name: 'player',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
    ],
  );
}

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String library = '/library';
  static const String player = '/player';
  
  // Note: These now are sub-routes, but we keep the constants for reference.
  // When navigating, we might need to be context-aware or just use absolute paths.
  // For simplicity in this app, we can rely on GoRouter resolving absolute paths 
  // to the active branch or specifically targeting a branch.
  
  // However, since we defined subroutes for each branch to keep bottom bar, 
  // navigating to '/album/123' might be ambiguous if we don't handle it.
  // But GoRouter matches top-down. 
  
  // A cleaner way for the rest of the app:
  // We can also keep global routes for album/artist/playlist if we want them to push 
  // onto the stack regardless of tab, OR we duplicate them in branches (as done above).
  // 
  // The duplicated subroutes allow browsing deeper into a tab.
}
