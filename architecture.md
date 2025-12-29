# EchoStream - Anonymous Music Streaming App Architecture

## Status: ✅ COMPLETED

## Overview
A fully functional, anonymous music streaming application inspired by Spotify, with a minimalist modern aesthetic. No authentication, no accounts, 100% local-first with all user data stored on device.

### Completed Features
✅ Music search (tracks, albums, artists, playlists)
✅ Audio streaming with just_audio
✅ Queue management with shuffle and repeat modes
✅ Liked songs (stored locally)
✅ User playlists (create, edit, delete)
✅ Album and artist detail pages
✅ Now playing screen with full controls
✅ Mini player with bottom navigation
✅ Recursive API response parsing
✅ Stream URL resolution (FLAC and manifest decoding)
✅ Local persistence with shared_preferences
✅ Vibrant, modern UI with purple/blue theme

## Technical Stack
- Flutter/Dart (latest)
- Local storage: shared_preferences
- Audio playback: just_audio
- HTTP client: http
- State management: Provider
- Navigation: go_router

## Core Principles
- 100% anonymous usage
- No authentication/accounts
- All user data stored locally
- Clean, layered architecture
- Strong typing and null safety
- API behavior followed exactly as specified

## API Architecture

### Base URL
`https://tidal.kinoplus.online`

### Key Characteristics
- Inconsistent response structures requiring recursive JSON traversal
- Dynamic nesting requiring normalization layer
- Temporary stream URLs requiring re-fetch on expiration
- No authentication required

## Data Models (lib/models/)

### Core Models
1. **Track** - Normalized track with metadata
2. **Album** - Album metadata
3. **Artist** - Artist information
4. **Playlist** - User-created playlist (local)
5. **PlaylistPreview** - API playlist preview
6. **StreamInfo** - Resolved stream URL and metadata
7. **PlaybackState** - Current queue and player state

### Model Features
- All models with toJson/fromJson
- Nullable fields where API is inconsistent
- Image URL generation helpers
- Duration handling in seconds

## Service Layer (lib/services/)

### 1. API Client Service
- Raw HTTP requests
- Error handling
- Response caching (short-term)
- Base URL configuration

### 2. Search Service
- Recursive JSON traversal to find 'items' arrays
- Track/Album/Artist/Playlist search
- Normalization of inconsistent API responses
- Debounced search

### 3. Track Service
- Track metadata fetch
- Stream URL resolution (FLAC or manifest decode)
- Manifest parsing (Base64 → JSON/regex)
- Stream URL caching with expiration

### 4. Album Service
- Album details fetch
- Track list extraction and normalization
- Missing metadata reconstruction

### 5. Playlist Service (API)
- Editorial playlist fetch
- Track extraction

### 6. Artist Service
- Artist metadata fetch
- Artist content feed fetch
- Album/EP/Singles extraction
- Fallback album search by name
- Data merging

### 7. Liked Songs Service (Local)
- Set<int> of track IDs
- Add/remove/check operations
- Persistence with shared_preferences

### 8. User Playlist Service (Local)
- Create/update/delete playlists
- Track management (add/remove/reorder)
- UUID generation for playlist IDs
- Persistence with shared_preferences
- Lazy track resolution by ID

### 9. Playback Service
- Audio player management (just_audio)
- Queue management
- Play/pause/seek/next/previous
- Shuffle/repeat modes
- Stream URL resolution and retry
- Current track state
- Progress tracking
- Error handling

## UI Architecture (lib/screens/)

### Navigation Structure
1. **Main Shell** (Bottom navigation)
   - Home/Discover
   - Search
   - Library

2. **Home Screen**
   - Featured content
   - Recently played
   - Recommended playlists

3. **Search Screen**
   - Search input with debounce
   - Tab view: Tracks/Albums/Artists/Playlists
   - Result lists with cards

4. **Library Screen**
   - Liked Songs
   - User Playlists
   - Create playlist button

5. **Album Detail Screen**
   - Album art and metadata
   - Track list
   - Play album button

6. **Artist Detail Screen**
   - Artist image and name
   - Top tracks
   - Albums/EPs/Singles tabs

7. **Playlist Detail Screen**
   - Playlist info
   - Track list
   - Edit/delete for user playlists

8. **Now Playing Screen**
   - Large album art
   - Track info
   - Playback controls
   - Progress bar
   - Queue view

## Providers (lib/providers/)

1. **PlaybackProvider**
   - Wraps PlaybackService
   - Notifies UI of state changes
   - Current track, queue, position
   - Player controls

2. **LikedSongsProvider**
   - Wraps LikedSongsService
   - Track like/unlike
   - Check if track is liked

3. **UserPlaylistProvider**
   - Wraps UserPlaylistService
   - Playlist CRUD
   - Track management

## Widgets (lib/widgets/)

### Reusable Components
1. **TrackListTile** - Track item with play button, title, artist, duration, like button
2. **AlbumCard** - Album cover with title and artist
3. **ArtistCard** - Circular artist image with name
4. **PlaylistCard** - Playlist cover with title and track count
5. **PlayerControls** - Play/pause, next/previous buttons
6. **ProgressBar** - Seekable progress indicator
7. **MiniPlayer** - Bottom mini player bar
8. **SearchBar** - Custom search input
9. **LoadingIndicator** - Consistent loading state
10. **EmptyState** - Empty state with message

## Design System

### Color Palette (Music App - Vibrant & Energetic)
- Light Mode:
  - Primary: Vibrant purple (#8B5CF6)
  - Secondary: Electric blue (#3B82F6)
  - Background: Pure white (#FFFFFF)
  - Surface: Light gray (#F9FAFB)
  - Accent: Pink (#EC4899)

- Dark Mode:
  - Primary: Lighter purple (#A78BFA)
  - Secondary: Brighter blue (#60A5FA)
  - Background: Deep black (#0A0A0A)
  - Surface: Dark gray (#1A1A1A)
  - Accent: Bright pink (#F472B6)

### Typography
- Primary: Inter (already configured)
- Hierarchy: Clear sizing for headers, titles, body, captions

### Spacing
- Generous padding and margins
- Card-based layouts
- Rounded corners (16-24px)

## Implementation Steps

1. **Setup & Dependencies**
   - Add required packages
   - Update theme with music app colors

2. **Data Models**
   - Define all models with serialization
   - Image URL helpers

3. **API Layer**
   - API client service
   - Search service with recursive traversal
   - Track service with stream resolution
   - Album/Artist/Playlist services

4. **Local Storage**
   - Liked songs service
   - User playlist service
   - Playback state persistence

5. **Playback Engine**
   - Audio player integration
   - Queue management
   - State tracking

6. **Providers**
   - Playback provider
   - Liked songs provider
   - User playlist provider

7. **UI Components**
   - Reusable widgets
   - Navigation shell
   - Screen implementations

8. **Integration & Testing**
   - Connect all layers
   - Error handling
   - Edge cases

9. **Polish**
   - Animations
   - Loading states
   - Empty states
   - Error messages

10. **Debugging**
    - Compile project
    - Fix errors
    - Test functionality

## Error Handling

- Network errors: Show retry option
- Empty results: Display empty state
- Missing fields: Graceful fallbacks
- Expired streams: Auto re-fetch
- Invalid manifests: Log and skip

## Performance Optimizations

- Debounce search input (300ms)
- Cache search results (5 min)
- Lazy load images
- Dispose audio resources properly
- Minimize rebuilds with proper provider scoping

## Future Enhancements
- Download for offline playback
- Lyrics display
- Audio equalizer
- Sleep timer
- Crossfade
- Gapless playback
