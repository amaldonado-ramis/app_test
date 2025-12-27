import 'package:echobeat/models/audio_quality.dart';

class Album {
  final String id;
  final String title;
  final String artist;
  final int artistId;
  final String? cover;
  final String? releaseDate;
  final String? genre;
  final int trackCount;
  final AudioQuality? audioQuality;
  final AlbumImages? images;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    this.cover,
    this.releaseDate,
    this.genre,
    required this.trackCount,
    this.audioQuality,
    this.images,
  });

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    id: json['id']?.toString() ?? '',
    title: json['title'] as String? ?? '',
    artist: json['artist'] as String? ?? '',
    artistId: json['artistId'] as int? ?? 0,
    cover: json['cover'] as String?,
    releaseDate: json['releaseDate'] as String?,
    genre: json['genre'] as String?,
    trackCount: json['trackCount'] as int? ?? 0,
    audioQuality: json['audioQuality'] != null
        ? AudioQuality.fromJson(json['audioQuality'])
        : null,
    images: json['images'] != null ? AlbumImages.fromJson(json['images']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'artistId': artistId,
    'cover': cover,
    'releaseDate': releaseDate,
    'genre': genre,
    'trackCount': trackCount,
    'audioQuality': audioQuality?.toJson(),
    'images': images?.toJson(),
  };

  String get coverUrl => images?.large ?? cover ?? '';
}

class AlbumImages {
  final String? small;
  final String? thumbnail;
  final String? large;

  AlbumImages({this.small, this.thumbnail, this.large});

  factory AlbumImages.fromJson(Map<String, dynamic> json) => AlbumImages(
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
