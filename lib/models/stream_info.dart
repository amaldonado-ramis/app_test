class StreamInfo {
  final String url;
  final String? quality;
  final DateTime fetchedAt;

  StreamInfo({
    required this.url,
    this.quality,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  bool get isExpired {
    final now = DateTime.now();
    return now.difference(fetchedAt).inHours > 6;
  }

  factory StreamInfo.fromJson(Map<String, dynamic> json) {
    return StreamInfo(
      url: json['url'],
      quality: json['quality'],
      fetchedAt: json['fetchedAt'] != null 
        ? DateTime.parse(json['fetchedAt']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    if (quality != null) 'quality': quality,
    'fetchedAt': fetchedAt.toIso8601String(),
  };
}
