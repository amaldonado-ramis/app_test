import 'package:flutter/foundation.dart';
import 'package:rhapsody/models/artist.dart';
import 'package:rhapsody/models/album.dart';
import 'package:rhapsody/models/track.dart';
import 'package:rhapsody/services/api/tidal_api_client.dart';
import 'package:rhapsody/services/api/search_normalizer.dart';
import 'package:rhapsody/services/api/album_api.dart';

class ArtistApi {
  final TidalApiClient _client;
  final AlbumApi _albumApi;

  ArtistApi(this._client, this._albumApi);

  Future<List<Artist>> searchArtists(String query) async {
    try {
      final response = await _client.get('/search/', queryParams: {'a': query});
      final items = SearchNormalizer.extractItems(response, entityType: 'artist');
      return items.map((json) => Artist.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching artists: $e');
      return [];
    }
  }

  Future<ArtistPage?> getArtistPage(int artistId) async {
    try {
      Artist? artistInfo;
      try {
        final metadataResponse = await _client.get('/artist/', queryParams: {'id': artistId.toString()});
        if (metadataResponse is Map<String, dynamic>) {
          artistInfo = Artist.fromJson(metadataResponse);
        }
      } catch (e) {
        debugPrint('Error fetching artist metadata: $e');
      }

      List<Album> albums = [];
      List<Album> eps = [];
      List<Track> topTracks = [];

      try {
        final feedResponse = await _client.get('/artist/', queryParams: {'f': artistId.toString()});
        
        // Try precise parsing first as per user instructions
        List<dynamic> albumItemsRaw = [];
        List<dynamic> topHitsRaw = [];

        if (feedResponse is Map<String, dynamic>) {
          // Check for albums in various locations
          if (feedResponse['albums'] is Map && feedResponse['albums']['items'] is List) {
            albumItemsRaw = feedResponse['albums']['items'];
          } else if (feedResponse['albums'] is List) {
             albumItemsRaw = feedResponse['albums'];
          }
          
          // Check for top hits
          if (feedResponse['topHits'] is List) {
            topHitsRaw = feedResponse['topHits'];
          } else if (feedResponse['tracks'] is List) {
             topHitsRaw = feedResponse['tracks'];
          }
        }

        // Parse Albums
        if (albumItemsRaw.isNotEmpty) {
          for (var item in albumItemsRaw) {
             try {
                // strict check: it must look like an album
                if (item['title'] == null) continue;
                
                final album = Album.fromJson(item);
                final type = album.type?.toUpperCase();
                if (type == 'EP' || type == 'SINGLE') {
                  eps.add(album);
                } else {
                  albums.add(album);
                }
             } catch (e) {
                // ignore invalid items
             }
          }
        } else {
           // Fallback to recursive search if precise parsing failed/empty
           final albumItems = SearchNormalizer.extractAlbumsFromAny(feedResponse);
            for (var item in albumItems) {
              try {
                final album = Album.fromJson(item);
                // Avoid duplicates if we somehow got them
                if (albums.any((a) => a.id == album.id) || eps.any((e) => e.id == album.id)) continue;

                final type = album.type?.toUpperCase();
                if (type == 'EP' || type == 'SINGLE') {
                  eps.add(album);
                } else {
                  albums.add(album);
                }
              } catch (e) {
                debugPrint('Error parsing album from feed: $e');
              }
            }
        }

        // Parse Top Tracks
        if (topHitsRaw.isNotEmpty) {
           topTracks = topHitsRaw.map((json) {
            try {
              // CRITICAL FIX: Ensure it is NOT an album
              if (json['numberOfTracks'] != null || json['type'] == 'ALBUM' || json['type'] == 'EP') {
                return null;
              }
              return Track.fromJson(json);
            } catch (e) {
              return null;
            }
          }).whereType<Track>().toList();
        } 
        
        // If topTracks is empty OR if we suspect the previous parsing failed (too few tracks), fallback
        if (topTracks.isEmpty) {
           // Fallback to recursive search
           final trackItems = SearchNormalizer.extractTracksFromAny(feedResponse);
           topTracks = trackItems.map((json) {
              try {
                // Double check it's not an album
                 if (json['numberOfTracks'] != null) return null;
                return Track.fromJson(json);
              } catch (e) {
                debugPrint('Error parsing track: $e');
                return null;
              }
            }).whereType<Track>().toList();
        }

      } catch (e) {
        debugPrint('Error fetching artist feed: $e');
      }

      if (artistInfo == null) {
        if (topTracks.isNotEmpty) {
          artistInfo = topTracks.first.artist;
        } else if (albums.isNotEmpty && albums.first.artists?.isNotEmpty == true) {
          artistInfo = albums.first.artists!.first;
        } else {
          artistInfo = Artist(id: artistId, name: 'Unknown Artist');
        }
      }

      // Fallback: If no albums found in feed, search for them
      if (albums.isEmpty && eps.isEmpty && artistInfo != null) {
        try {
          final searchedAlbums = await _albumApi.searchAlbums(artistInfo.name);
          // Filter to keep only albums by this artist
          final filteredAlbums = searchedAlbums.where((album) {
            final idMatch = album.artists?.any((a) => a.id == artistId) ?? false;
            if (idMatch) return true;
            
            // Name match fallback (case insensitive)
            final nameMatch = album.artists?.any((a) => a.name.toLowerCase() == artistInfo!.name.toLowerCase()) ?? false;
            return nameMatch;
          }).toList();
          
          for (var album in filteredAlbums) {
            final type = album.type?.toUpperCase();
            if (type == 'EP' || type == 'SINGLE') {
              eps.add(album);
            } else {
              albums.add(album);
            }
          }
        } catch (e) {
          debugPrint('Error searching artist albums: $e');
        }
      }

      // Fallback: If no top tracks found, search for them
      if (topTracks.isEmpty && artistInfo != null) {
         try {
           final response = await _client.get('/search/', queryParams: {'s': artistInfo.name});
           final items = SearchNormalizer.extractTracksFromAny(response);
           final tracks = items.map((json) => Track.fromJson(json)).toList();
           
           // Filter strictly by artist name
           topTracks = tracks.where((t) => 
             t.artist.name.toLowerCase() == artistInfo!.name.toLowerCase() || 
             t.artist.id == artistId
           ).take(10).toList();
         } catch (e) {
            debugPrint('Error searching artist top tracks: $e');
         }
      }

      return ArtistPage(
        artist: artistInfo,
        albums: albums,
        eps: eps,
        topTracks: topTracks,
      );
    } catch (e) {
      debugPrint('Error getting artist page: $e');
      return null;
    }
  }
}

class ArtistPage {
  final Artist artist;
  final List<Album> albums;
  final List<Album> eps;
  final List<Track> topTracks;

  ArtistPage({
    required this.artist,
    required this.albums,
    required this.eps,
    required this.topTracks,
  });
}
