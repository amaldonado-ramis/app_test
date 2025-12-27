class Pagination {
  final int offset;
  final int limit;
  final int total;
  final bool hasMore;
  final int returned;

  Pagination({
    required this.offset,
    required this.limit,
    required this.total,
    required this.hasMore,
    required this.returned,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    offset: json['offset'] as int? ?? 0,
    limit: json['limit'] as int? ?? 0,
    total: json['total'] as int? ?? 0,
    hasMore: json['hasMore'] as bool? ?? false,
    returned: json['returned'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'offset': offset,
    'limit': limit,
    'total': total,
    'hasMore': hasMore,
    'returned': returned,
  };
}
