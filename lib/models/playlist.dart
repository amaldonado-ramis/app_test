class Playlist {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<int> trackIds;

  Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.trackIds,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    trackIds: (json['trackIds'] as List).map((e) => e as int).toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'trackIds': trackIds,
  };

  Playlist copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<int>? trackIds,
  }) => Playlist(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    trackIds: trackIds ?? this.trackIds,
  );
}
