import 'package:rhapsody/models/artist.dart';
import 'package:rhapsody/models/album.dart';

class Track {
  final int id;
  final String title;
  final int duration;
  final Artist artist;
  final List<Artist>? artists;
  final Album? album;
  final String? audioQuality;
  final int? popularity;

  Track({
    required this.id,
    required this.title,
    required this.duration,
    required this.artist,
    this.artists,
    this.album,
    this.audioQuality,
    this.popularity,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    Artist primaryArtist;
    if (json['artist'] != null) {
      primaryArtist = Artist.fromJson(json['artist']);
    } else if (json['artists'] != null && (json['artists'] as List).isNotEmpty) {
      primaryArtist = Artist.fromJson((json['artists'] as List).first);
    } else {
      primaryArtist = Artist(id: 0, name: 'Unknown Artist');
    }

    List<Artist>? artistsList;
    if (json['artists'] != null) {
      artistsList = (json['artists'] as List)
          .map((a) => Artist.fromJson(a))
          .toList();
    }

    Album? albumData;
    if (json['album'] != null) {
      albumData = Album.fromJson(json['album']);
    }

    return Track(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      duration: json['duration'] ?? 0,
      artist: primaryArtist,
      artists: artistsList,
      album: albumData,
      audioQuality: json['audioQuality'],
      popularity: json['popularity'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'duration': duration,
    'artist': artist.toJson(),
    if (artists != null) 'artists': artists!.map((a) => a.toJson()).toList(),
    if (album != null) 'album': album!.toJson(),
    if (audioQuality != null) 'audioQuality': audioQuality,
    if (popularity != null) 'popularity': popularity,
  };

  Track copyWith({
    int? id,
    String? title,
    int? duration,
    Artist? artist,
    List<Artist>? artists,
    Album? album,
    String? audioQuality,
    int? popularity,
  }) => Track(
    id: id ?? this.id,
    title: title ?? this.title,
    duration: duration ?? this.duration,
    artist: artist ?? this.artist,
    artists: artists ?? this.artists,
    album: album ?? this.album,
    audioQuality: audioQuality ?? this.audioQuality,
    popularity: popularity ?? this.popularity,
  );

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get artistNames {
    if (artists != null && artists!.isNotEmpty) {
      return artists!.map((a) => a.name).join(', ');
    }
    return artist.name;
  }

  String? get albumCoverUrl => album?.getCoverUrl();
}
