class Artist {
  final int id;
  final String name;
  final String? picture;
  final String? type;

  Artist({
    required this.id,
    required this.name,
    this.picture,
    this.type,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      picture: json['picture'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (picture != null) 'picture': picture,
    if (type != null) 'type': type,
  };

  Artist copyWith({
    int? id,
    String? name,
    String? picture,
    String? type,
  }) => Artist(
    id: id ?? this.id,
    name: name ?? this.name,
    picture: picture ?? this.picture,
    type: type ?? this.type,
  );

  String getPictureUrl({int size = 750}) {
    if (picture == null || picture!.isEmpty) return '';
    final idWithSlashes = picture!.split('-').join('/');

    return 'https://resources.tidal.com/images/$idWithSlashes/${size}x$size.jpg';
  }
}
