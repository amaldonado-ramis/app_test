class Playlist {
  final String id;
  final String title;
  final int numberOfTracks;
  final String? description;
  final String? image;

  Playlist({
    required this.id,
    required this.title,
    required this.numberOfTracks,
    this.description,
    this.image,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      numberOfTracks: json['numberOfTracks'] ?? json['trackCount'] ?? 0,
      description: json['description'],
      image: json['image'] ?? json['squareImage'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'numberOfTracks': numberOfTracks,
    if (description != null) 'description': description,
    if (image != null) 'image': image,
  };

  Playlist copyWith({
    String? id,
    String? title,
    int? numberOfTracks,
    String? description,
    String? image,
  }) => Playlist(
    id: id ?? this.id,
    title: title ?? this.title,
    numberOfTracks: numberOfTracks ?? this.numberOfTracks,
    description: description ?? this.description,
    image: image ?? this.image,
  );

  String getImageUrl({int size = 1280}) {
    if (image == null || image!.isEmpty) return '';
    final idStr = image!.replaceAll('-', '');
    final segments = <String>[];
    for (int i = 0; i < idStr.length; i += 4) {
      segments.add(idStr.substring(i, (i + 4).clamp(0, idStr.length)));
    }
    return 'https://resources.tidal.com/images/${segments.join('/')}/${size}x$size.jpg';
  }
}
