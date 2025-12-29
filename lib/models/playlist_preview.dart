class PlaylistPreview {
  final String id;
  final String title;
  final int numberOfTracks;
  final String? description;
  final String? image;

  PlaylistPreview({
    required this.id,
    required this.title,
    required this.numberOfTracks,
    this.description,
    this.image,
  });

  factory PlaylistPreview.fromJson(Map<String, dynamic> json) {
    return PlaylistPreview(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      numberOfTracks: json['numberOfTracks'] as int? ?? 0,
      description: json['description'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'numberOfTracks': numberOfTracks,
    'description': description,
    'image': image,
  };
}
