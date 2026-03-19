import 'package:flutter/material.dart';
import '../models/suggestion.dart';
import '../services/api_service.dart';

class SuggestionsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Suggestion> _suggestions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Pagination? _pagination;
  String? _error;

  List<Suggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  Pagination? get pagination => _pagination;
  String? get error => _error;

  Future<void> fetchSuggestions({bool isRefresh = false}) async {
    if (isRefresh) {
      _suggestions = [];
      _pagination = null;
    }

    if (_isLoading || (_pagination != null && !_pagination!.hasNext && !isRefresh)) return;

    if (_suggestions.isEmpty) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final nextPage = isRefresh ? 1 : (_pagination?.currentPage ?? 0) + 1;
      final response = await _apiService.getSuggestions(page: nextPage);
      
      if (isRefresh) {
        _suggestions = response.data;
      } else {
        _suggestions.addAll(response.data);
      }
      _pagination = response.pagination;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
