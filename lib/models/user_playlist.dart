class UserPlaylist {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<int> trackIds;

  UserPlaylist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.trackIds,
  });

  factory UserPlaylist.fromJson(Map<String, dynamic> json) {
    return UserPlaylist(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      trackIds: List<int>.from(json['trackIds']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'trackIds': trackIds,
  };

  UserPlaylist copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<int>? trackIds,
  }) => UserPlaylist(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    trackIds: trackIds ?? this.trackIds,
  );

  int get trackCount => trackIds.length;
}
