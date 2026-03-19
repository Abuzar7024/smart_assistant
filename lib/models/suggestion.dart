class Suggestion {
  final int id;
  final String title;
  final String description;

  Suggestion({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      totalItems: json['total_items'],
      limit: json['limit'],
      hasNext: json['has_next'],
      hasPrevious: json['has_previous'],
    );
  }
}

class SuggestionResponse {
  final String status;
  final List<Suggestion> data;
  final Pagination pagination;

  SuggestionResponse({
    required this.status,
    required this.data,
    required this.pagination,
  });

  factory SuggestionResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionResponse(
      status: json['status'],
      data: (json['data'] as List).map((i) => Suggestion.fromJson(i)).toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}
