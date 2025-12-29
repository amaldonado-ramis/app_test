import 'package:echostream/models/album.dart';
import 'package:echostream/models/artist.dart';
import 'package:echostream/models/track.dart';
import 'package:echostream/services/api_client.dart';
import 'package:echostream/services/search_service.dart';
import 'package:flutter/foundation.dart';

class ArtistService {
  final ApiClient _client = ApiClient();
  final SearchService _searchService = SearchService();

  Future<ArtistDetails?> getArtistDetails(int artistId) async {
    try {
      final metadataResponse = await _client.get('/artist/?id=$artistId');
      
      dynamic metaData = metadataResponse;
      if (metaData is Map && metaData.containsKey('data')) {
        metaData = metaData['data'];
      }
      if (metaData is List && metaData.isNotEmpty) {
        metaData = metaData.first;
      }

      Artist artist = metaData is Map<String, dynamic>
          ? Artist.fromJson(metaData)
          : Artist(id: artistId, name: 'Unknown Artist');

      final contentResponse = await _client.get('/artist/?f=$artistId');
      
      List<Album> albums = [];
      List<Album> eps = [];
      List<Track> topTracks = [];

      _extractContent(contentResponse, albums, eps, topTracks);

      final searchedAlbums = await _searchService.searchAlbums(artist.name);
      for (var album in searchedAlbums) {
        if (!albums.any((a) => a.id == album.id) && !eps.any((e) => e.id == album.id)) {
          if (album.type?.toLowerCase() == 'ep' || album.type?.toLowerCase() == 'single') {
            eps.add(album);
          } else {
            albums.add(album);
          }
        }
      }

      return ArtistDetails(
        artist: artist,
        albums: albums,
        eps: eps,
        topTracks: topTracks,
      );
    } catch (e) {
      debugPrint('Error fetching artist details: $e');
      return null;
    }
  }

  void _extractContent(dynamic json, List<Album> albums, List<Album> eps, List<Track> tracks) {
    if (json == null) return;

    if (json is Map<String, dynamic>) {
      if (json.containsKey('items') && json['items'] is List) {
        final items = json['items'] as List;
        for (var item in items) {
          if (item is! Map<String, dynamic>) continue;

          try {
            if (item['type'] == 'album' || item.containsKey('numberOfTracks')) {
              final album = Album.fromJson(item);
              if (album.type?.toLowerCase() == 'ep' || album.type?.toLowerCase() == 'single') {
                eps.add(album);
              } else {
                albums.add(album);
              }
            } else if (item['type'] == 'track' || item.containsKey('duration')) {
              tracks.add(Track.fromJson(item));
            }
          } catch (e) {
            debugPrint('Error parsing item: $e');
          }
        }
      }

      for (var value in json.values) {
        _extractContent(value, albums, eps, tracks);
      }
    } else if (json is List) {
      for (var item in json) {
        _extractContent(item, albums, eps, tracks);
      }
    }
  }
}

class ArtistDetails {
  final Artist artist;
  final List<Album> albums;
  final List<Album> eps;
  final List<Track> topTracks;

  ArtistDetails({
    required this.artist,
    required this.albums,
    required this.eps,
    required this.topTracks,
  });
}
