class AudioQuality {
  final int maximumBitDepth;
  final int maximumSamplingRate;
  final bool isHiRes;

  AudioQuality({
    required this.maximumBitDepth,
    required this.maximumSamplingRate,
    required this.isHiRes,
  });

  factory AudioQuality.fromJson(Map<String, dynamic> json) => AudioQuality(
    maximumBitDepth: json['maximumBitDepth'] as int? ?? 0,
    maximumSamplingRate: json['maximumSamplingRate'] as int? ?? 0,
    isHiRes: json['isHiRes'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'maximumBitDepth': maximumBitDepth,
    'maximumSamplingRate': maximumSamplingRate,
    'isHiRes': isHiRes,
  };
}
