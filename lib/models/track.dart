import 'package:echobeat/models/audio_quality.dart';

class Track {
  final int id;
  final String title;
  final String artist;
  final int artistId;
  final String albumTitle;
  final String? albumCover;
  final String albumId;
  final String? releaseDate;
  final String? genre;
  final int duration;
  final AudioQuality? audioQuality;
  final bool parentalWarning;
  final bool streamable;
  final TrackImages? images;
  final String? isrc;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.albumTitle,
    this.albumCover,
    required this.albumId,
    this.releaseDate,
    this.genre,
    required this.duration,
    this.audioQuality,
    this.parentalWarning = false,
    this.streamable = true,
    this.images,
    this.isrc,
  });

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    artist: json['artist'] as String? ?? '',
    artistId: json['artistId'] as int? ?? 0,
    albumTitle: json['albumTitle'] as String? ?? '',
    albumCover: json['albumCover'] as String?,
    albumId: json['albumId']?.toString() ?? '',
    releaseDate: json['releaseDate'] as String?,
    genre: json['genre'] as String?,
    duration: json['duration'] as int? ?? 0,
    audioQuality: json['audioQuality'] != null
        ? AudioQuality.fromJson(json['audioQuality'])
        : null,
    parentalWarning: json['parental_warning'] as bool? ?? false,
    streamable: json['streamable'] as bool? ?? true,
    images: json['images'] != null ? TrackImages.fromJson(json['images']) : null,
    isrc: json['isrc'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'artistId': artistId,
    'albumTitle': albumTitle,
    'albumCover': albumCover,
    'albumId': albumId,
    'releaseDate': releaseDate,
    'genre': genre,
    'duration': duration,
    'audioQuality': audioQuality?.toJson(),
    'parental_warning': parentalWarning,
    'streamable': streamable,
    'images': images?.toJson(),
    'isrc': isrc,
  };

  Track copyWith({
    int? id,
    String? title,
    String? artist,
    int? artistId,
    String? albumTitle,
    String? albumCover,
    String? albumId,
    String? releaseDate,
    String? genre,
    int? duration,
    AudioQuality? audioQuality,
    bool? parentalWarning,
    bool? streamable,
    TrackImages? images,
    String? isrc,
  }) => Track(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    artistId: artistId ?? this.artistId,
    albumTitle: albumTitle ?? this.albumTitle,
    albumCover: albumCover ?? this.albumCover,
    albumId: albumId ?? this.albumId,
    releaseDate: releaseDate ?? this.releaseDate,
    genre: genre ?? this.genre,
    duration: duration ?? this.duration,
    audioQuality: audioQuality ?? this.audioQuality,
    parentalWarning: parentalWarning ?? this.parentalWarning,
    streamable: streamable ?? this.streamable,
    images: images ?? this.images,
    isrc: isrc ?? this.isrc,
  );

  String get coverUrl => images?.large ?? albumCover ?? '';
  
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class TrackImages {
  final String? small;
  final String? thumbnail;
  final String? large;

  TrackImages({this.small, this.thumbnail, this.large});

  factory TrackImages.fromJson(Map<String, dynamic> json) => TrackImages(
    small: json['small'] as String?,
    thumbnail: json['thumbnail'] as String?,
    large: json['large'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'small': small,
    'thumbnail': thumbnail,
    'large': large,
  };
}
