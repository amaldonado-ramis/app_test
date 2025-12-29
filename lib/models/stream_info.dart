class StreamInfo {
  final String url;
  final String quality;
  final DateTime fetchedAt;

  StreamInfo({
    required this.url,
    required this.quality,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  bool get isExpired {
    final now = DateTime.now();
    final age = now.difference(fetchedAt);
    return age.inHours >= 1;
  }

  factory StreamInfo.fromJson(Map<String, dynamic> json) {
    return StreamInfo(
      url: json['url'] as String,
      quality: json['quality'] as String,
      fetchedAt: json['fetchedAt'] != null 
        ? DateTime.parse(json['fetchedAt'] as String)
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'quality': quality,
    'fetchedAt': fetchedAt.toIso8601String(),
  };
}
