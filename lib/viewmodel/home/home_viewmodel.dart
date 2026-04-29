import 'package:flutter/material.dart';
import '../../model/home/news_article.dart';

class HomeViewModel extends ChangeNotifier {
  final List<NewsArticle> _newsArticles = [];
  bool _isLoading = false;
  String _error = '';

  List<NewsArticle> get newsArticles => _newsArticles;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchNewsArticles() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulated delay for API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample data
      _newsArticles.addAll([
        NewsArticle(
          id: '1',
          category: 'General',
          title: 'Breaking News',
          description: 'Latest news update',
          imagePath: 'assets/svgimages/general.svg',
          publishedDate: DateTime.now(),
          author: 'Author Name',
        ),
      ]);

      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
