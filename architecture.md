# Anonymous Music Streaming App Architecture

## Overview
Production-grade, anonymous music streaming application with local-first data persistence, comparable to Spotify in functionality.

## Core Principles
- **Zero Authentication**: No login, signup, accounts, or user identification
- **Privacy-First**: All user data stored locally on device
- **Offline-Capable**: Works with cached metadata when offline
- **Production-Grade**: Real, daily-use quality playback and UI

## Architecture Layers

### 1. Data Models (`lib/models/`)
Strongly-typed, null-safe domain models:
- `track.dart` - Track metadata with artist, album, duration
- `album.dart` - Album with tracks and release info
- `artist.dart` - Artist with picture and metadata
- `playlist.dart` - Editorial and user-created playlists
- `user_playlist.dart` - Local user playlists with UUID
- `playback_state.dart` - Queue, shuffle, repeat mode
- `stream_info.dart` - Resolved stream URL and quality

### 2. API Client (`lib/services/api/`)
- `tidal_api_client.dart` - HTTP client wrapper for base URL
- `search_normalizer.dart` - Recursive JSON traversal and entity extraction
- `track_api.dart` - Track search and stream resolution
- `album_api.dart` - Album search and details
- `artist_api.dart` - Artist search, details, and feed parsing
- `playlist_api.dart` - Editorial playlist search and details
- `image_resolver.dart` - Cover art URL generation

### 3. Local Storage (`lib/services/storage/`)
- `liked_songs_storage.dart` - Set<int> of liked track IDs
- `user_playlists_storage.dart` - List of user playlists
- `playback_state_storage.dart` - Queue and position persistence
- `cache_storage.dart` - Short-term metadata caching

### 4. Playback Engine (`lib/services/playback/`)
- `audio_player_service.dart` - Core playback with just_audio
- `queue_manager.dart` - Queue, shuffle, repeat logic
- `playback_controller.dart` - High-level playback facade

### 5. State Management (`lib/providers/`)
- `playback_provider.dart` - Current track, queue, controls
- `library_provider.dart` - Liked songs, user playlists
- `search_provider.dart` - Search state and results

### 6. UI (`lib/screens/`)
Main navigation:
- `home_screen.dart` - Browse, discover, continue listening
- `search_screen.dart` - Multi-tab search (tracks, albums, artists, playlists)
- `library_screen.dart` - Liked songs and user playlists
- `player_screen.dart` - Full-screen now playing

Detail screens:
- `album_detail_screen.dart` - Album cover, tracks, play all
- `artist_detail_screen.dart` - Top tracks, albums, EPs
- `playlist_detail_screen.dart` - Editorial/user playlist tracks

### 7. UI Components (`lib/widgets/`)
- `track_list_item.dart` - Track row with artwork, title, artist
- `album_card.dart` - Square album artwork card
- `artist_card.dart` - Circular artist picture card
- `playlist_card.dart` - Playlist cover card
- `mini_player.dart` - Persistent bottom player bar
- `playback_controls.dart` - Play, pause, next, previous
- `seek_bar.dart` - Progress bar with seek
- `queue_sheet.dart` - Bottom sheet queue view

## API Integration Details

### Search Implementation
- Recursively traverse entire JSON response tree
- Detect entities by shape: `{ items: [...] }` pattern
- Normalize inconsistent structures into typed models
- Handle missing/null fields gracefully

### Stream Resolution
1. Check `OriginalTrackUrl` for direct FLAC
2. Decode base64 `manifest` field
3. Try parsing as JSON → extract `urls[0]`
4. Fallback: regex extract first `https://` URL
5. Stream URLs are temporary, re-fetch on expiry

### Artist Details
- Combine `/artist/?id=` (metadata) + `/artist/?f=` (feed)
- Recursively detect albums (has `numberOfTracks`) and tracks (has `duration`)
- Fallback: search albums by artist name
- Merge and deduplicate results

### Image URLs
Pattern: `https://resources.tidal.com/images/{id_with_slashes}/{size}x{size}.jpg`
- Album covers: 1280x1280
- Artist pictures: 750x750
- Convert ID to path with slashes every 4 chars

## Playback Features
- Play/pause, seek, next/previous
- Queue management (add, remove, reorder)
- Shuffle and repeat modes
- Background playback
- Lock screen controls
- Media notifications
- Auto-advance on track end
- Buffering states

## Local Storage Schema
```dart
// Liked songs: Set<int>
SharedPreferences: 'liked_song_ids' → JSON array

// User playlists: List<UserPlaylist>
SharedPreferences: 'user_playlists' → JSON array
UserPlaylist {
  id: UUID string
  name: string
  createdAt: ISO timestamp
  trackIds: int[]
}

// Playback state
SharedPreferences: 'playback_queue' → Track[] JSON
SharedPreferences: 'current_index' → int
SharedPreferences: 'shuffle_enabled' → bool
SharedPreferences: 'repeat_mode' → string ('off'|'all'|'one')
```

## UI/UX Design
- Minimalist, artwork-centric design
- Dark mode optimized color scheme
- Smooth page transitions
- Debounced search (300ms)
- Pull-to-refresh on lists
- Skeleton loading states
- Haptic feedback on actions
- Snackbar notifications for errors

## Navigation Structure
```
MainScaffold (persistent mini player)
├── BottomNavigationBar
│   ├── Home
│   ├── Search
│   └── Library
├── → AlbumDetailScreen
├── → ArtistDetailScreen
├── → PlaylistDetailScreen
└── → PlayerScreen (full screen modal)
```

## Dependencies
- `just_audio` - Audio playback engine
- `audio_service` - Background playback and media controls
- `shared_preferences` - Local data persistence
- `http` - API requests
- `provider` - State management
- `go_router` - Navigation
- `cached_network_image` - Image caching
- `uuid` - Playlist ID generation

## Implementation Priority
1. Data models with serialization
2. API client and normalization logic
3. Local storage services
4. Playback engine and queue manager
5. State providers
6. Main navigation scaffold with mini player
7. Search screen (tracks first, then multi-tab)
8. Album and artist detail screens
9. Library screen (liked songs, playlists)
10. Full player screen
11. Queue management UI
12. Playlist creation/editing
13. Polish, performance, error handling
14. Testing and debugging
