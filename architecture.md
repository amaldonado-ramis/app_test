# EchoBeat - Anonymous Music Streaming App Architecture

## Overview
EchoBeat is a fully functional, anonymous music streaming application inspired by Spotify. It provides track/album search, audio streaming, liked songs, and playlist management without any authentication or user accounts. All user data is stored locally.

## Architecture Layers

### 1. API Client Layer (`lib/services/api_client.dart`)
- HTTP client with cookie-based authentication
- Base URL: `https://dab.yeet.su/api`
- Session cookie management (JWT token)
- Request/response handling with proper error management
- Endpoints:
  - GET `/search?q=query&offset=0&type=track` - Search tracks
  - GET `/search?q=query&offset=0&type=album` - Search albums
  - GET `/stream?trackId=id` - Get streaming URL (no auth required)

### 2. Domain Models (`lib/models/`)
- `track.dart` - Track entity with full metadata
- `album.dart` - Album entity
- `playlist.dart` - Local playlist with metadata
- `audio_quality.dart` - Audio quality information
- `pagination.dart` - Pagination metadata
- `search_response.dart` - API response wrappers

### 3. Services (`lib/services/`)
- `api_service.dart` - High-level API operations (search, stream)
- `storage_service.dart` - Local persistence (SharedPreferences)
- `liked_songs_service.dart` - Manage liked tracks
- `playlist_service.dart` - CRUD operations for playlists
- `playback_service.dart` - Audio playback engine with state management

### 4. State Management (`lib/providers/`)
- `playback_provider.dart` - Current playback state, queue, controls
- `library_provider.dart` - Liked songs and playlists
- `search_provider.dart` - Search state with debouncing

### 5. UI Screens (`lib/screens/`)
- `home_screen.dart` - Main navigation hub with search
- `search_results_screen.dart` - Display search results
- `album_detail_screen.dart` - Album tracks view
- `liked_songs_screen.dart` - User's liked songs
- `playlists_screen.dart` - Playlist management
- `playlist_detail_screen.dart` - Individual playlist view
- `now_playing_screen.dart` - Full-screen player

### 6. UI Components (`lib/components/`)
- `track_tile.dart` - Reusable track list item
- `album_card.dart` - Album grid/list card
- `mini_player.dart` - Bottom mini player bar
- `player_controls.dart` - Play/pause/skip controls
- `progress_bar.dart` - Seekable progress indicator
- `search_bar_widget.dart` - Search input with debounce
- `playlist_tile.dart` - Playlist list item
- `add_to_playlist_dialog.dart` - Playlist selection dialog

## Data Flow

### Search Flow
1. User enters query in `SearchBarWidget`
2. `SearchProvider` debounces input (300ms)
3. `ApiService.searchTracks()` or `searchAlbums()` called
4. API response parsed into domain models
5. UI updates with results and pagination support

### Playback Flow
1. User selects track from any screen
2. `PlaybackProvider.playTrack()` called
3. `ApiService.getStreamUrl()` fetches temporary URL
4. `PlaybackService` loads URL into audio player
5. Playback state updates (playing, buffering, progress)
6. Mini player and now playing screen reflect state

### Local Storage Flow
1. Liked songs stored as Set<int> of track IDs
2. Playlists stored as List<Map> with metadata
3. Track metadata cached for quick access
4. All persistence via `StorageService` with JSON serialization

## Key Technical Decisions

1. **Cookie-based Authentication**: Use `http` package with custom headers/cookies for session JWT
2. **Local Storage**: SharedPreferences for all user data (no backend sync)
3. **Audio Playback**: `audioplayers` package for cross-platform streaming
4. **State Management**: Provider pattern for reactive UI
5. **Search Debouncing**: Timer-based debouncing to reduce API calls
6. **Pagination**: Offset-based pagination with "Load More" functionality
7. **Error Handling**: Graceful degradation with user-friendly messages

## Session Cookie Configuration

The session JWT cookie is configured via environment or hardcoded constant:
- Cookie name: `session`
- Value: JWT token string
- Applied to all authenticated API requests (except `/stream`)
- Store in `lib/config/api_config.dart` as a constant

## UI Design Approach

**Sophisticated Monochrome with Music-Forward Accent**
- Light Mode: White backgrounds (#FFFFFF), soft blue-grey cards (#F8FAFC)
- Dark Mode: Deep charcoal (#0F1419) with blue-grey elevations (#1A1F26)
- Accent: Vibrant purple/pink gradient for music branding (#8B5CF6 → #EC4899)
- Flat design, no shadows, generous spacing
- Inter font family throughout
- Rounded corners (12-16px) on all components

## Implementation Steps

1. ✅ Create architecture document
2. ✅ Add dependencies (http, audioplayers, shared_preferences, uuid)
3. ✅ Implement domain models with JSON serialization
4. ✅ Build API client with cookie support
5. ✅ Create service layer (API, storage, playback)
6. ✅ Implement state providers
7. ✅ Design and build reusable UI components
8. ✅ Construct all screens with navigation
9. ✅ Update theme with custom color palette
10. ✅ Add error handling and loading states
11. ✅ Test and debug with compile_project

## Future Enhancements (Not in MVP)
- Offline mode with downloaded tracks
- Advanced playlist features (reordering, duplicates)
- Track analytics and listening history
- Export/import playlists
- Lyrics display
- Equalizer and audio effects
