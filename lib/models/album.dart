import 'package:rhapsody/models/artist.dart';

class Album {
  final String id;
  final String title;
  final List<Artist>? artists;
  final int numberOfTracks;
  final String? releaseDate;
  final String? type;
  final String? cover;

  Album({
    required this.id,
    required this.title,
    this.artists,
    required this.numberOfTracks,
    this.releaseDate,
    this.type,
    this.cover,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    List<Artist>? artistsList;
    if (json['artists'] != null) {
      artistsList = (json['artists'] as List)
          .map((a) => Artist.fromJson(a))
          .toList();
    } else if (json['artist'] != null) {
      artistsList = [Artist.fromJson(json['artist'])];
    }

    return Album(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      artists: artistsList,
      numberOfTracks: json['numberOfTracks'] ?? 0,
      releaseDate: json['releaseDate'],
      type: json['type'],
      cover: json['cover'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (artists != null) 'artists': artists!.map((a) => a.toJson()).toList(),
    'numberOfTracks': numberOfTracks,
    if (releaseDate != null) 'releaseDate': releaseDate,
    if (type != null) 'type': type,
    if (cover != null) 'cover': cover,
  };

  Album copyWith({
    String? id,
    String? title,
    List<Artist>? artists,
    int? numberOfTracks,
    String? releaseDate,
    String? type,
    String? cover,
  }) => Album(
    id: id ?? this.id,
    title: title ?? this.title,
    artists: artists ?? this.artists,
    numberOfTracks: numberOfTracks ?? this.numberOfTracks,
    releaseDate: releaseDate ?? this.releaseDate,
    type: type ?? this.type,
    cover: cover ?? this.cover,
  );

  String getCoverUrl({int size = 1280}) {
    if (cover == null || cover!.isEmpty) return '';
    final idWithSlashes = cover!.split('-').join('/');
    
    return 'https://resources.tidal.com/images/$idWithSlashes/${size}x$size.jpg';
  }

  String get artistNames {
    if (artists == null || artists!.isEmpty) return 'Unknown Artist';
    return artists!.map((a) => a.name).join(', ');
  }
}
