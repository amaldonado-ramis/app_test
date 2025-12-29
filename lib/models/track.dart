import 'package:echostream/models/album.dart';
import 'package:echostream/models/artist.dart';

class Track {
  final int id;
  final String title;
  final int duration;
  final Artist? artist;
  final List<Artist>? artists;
  final Album? album;
  final String? audioQuality;
  final int? popularity;

  Track({
    required this.id,
    required this.title,
    required this.duration,
    this.artist,
    this.artists,
    this.album,
    this.audioQuality,
    this.popularity,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    Artist? primaryArtist;
    List<Artist>? artistList;

    if (json['artist'] != null) {
      primaryArtist = Artist.fromJson(json['artist'] as Map<String, dynamic>);
    }

    if (json['artists'] != null && json['artists'] is List) {
      artistList = (json['artists'] as List)
          .map((a) => Artist.fromJson(a as Map<String, dynamic>))
          .toList();
      primaryArtist ??= artistList.isNotEmpty ? artistList.first : null;
    }

    return Track(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      artist: primaryArtist,
      artists: artistList,
      album: json['album'] != null 
        ? Album.fromJson(json['album'] as Map<String, dynamic>)
        : null,
      audioQuality: json['audioQuality'] as String?,
      popularity: json['popularity'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'duration': duration,
    'artist': artist?.toJson(),
    'artists': artists?.map((a) => a.toJson()).toList(),
    'album': album?.toJson(),
    'audioQuality': audioQuality,
    'popularity': popularity,
  };

  String get artistName => artist?.name ?? 'Unknown Artist';
  
  String get albumTitle => album?.title ?? 'Unknown Album';
  
  String get albumCoverUrl => album?.getCoverUrl() ?? '';

  String formatDuration() {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

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
}
