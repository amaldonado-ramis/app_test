import 'package:echostream/models/artist.dart';

class Album {
  final String id;
  final String title;
  final Artist? artist;
  final int? numberOfTracks;
  final String? releaseDate;
  final String? type;
  final String? cover;

  Album({
    required this.id,
    required this.title,
    this.artist,
    this.numberOfTracks,
    this.releaseDate,
    this.type,
    this.cover,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] != null 
        ? Artist.fromJson(json['artist'] as Map<String, dynamic>)
        : null,
      numberOfTracks: json['numberOfTracks'] as int?,
      releaseDate: json['releaseDate'] as String?,
      type: json['type'] as String?,
      cover: json['cover'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist?.toJson(),
    'numberOfTracks': numberOfTracks,
    'releaseDate': releaseDate,
    'type': type,
    'cover': cover,
  };

  String getCoverUrl({int size = 1280}) {
    if (cover == null) return '';
    final idWithSlashes = cover!.replaceAllMapped(
      RegExp(r'(\w{1,4})'),
      (match) => '${match.group(1)}/',
    ).replaceAll(RegExp(r'/$'), '');
    return 'https://resources.tidal.com/images/$idWithSlashes/${size}x$size.jpg';
  }

  Album copyWith({
    String? id,
    String? title,
    Artist? artist,
    int? numberOfTracks,
    String? releaseDate,
    String? type,
    String? cover,
  }) => Album(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    numberOfTracks: numberOfTracks ?? this.numberOfTracks,
    releaseDate: releaseDate ?? this.releaseDate,
    type: type ?? this.type,
    cover: cover ?? this.cover,
  );
}
