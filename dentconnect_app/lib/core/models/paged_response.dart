class PagedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;
  final bool last;

  const PagedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    return PagedResponse<T>(
      content: rawContent.map((e) => fromJsonT(e)).toList(),
      page: json['page'] as int? ?? json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }

  @override
  String toString() =>
      'PagedResponse(page: $page, size: $size, totalPages: $totalPages, totalElements: $totalElements, last: $last)';
}
