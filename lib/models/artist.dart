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
      id: json['id'] as int,
      name: json['name'] as String,
      picture: json['picture'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'picture': picture,
    'type': type,
  };

  String getPictureUrl({int size = 750}) {
    if (picture == null) return '';
    final idWithSlashes = picture!.replaceAllMapped(
      RegExp(r'(\w{1,4})'),
      (match) => '${match.group(1)}/',
    ).replaceAll(RegExp(r'/$'), '');
    return 'https://resources.tidal.com/images/$idWithSlashes/${size}x$size.jpg';
  }

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
}
