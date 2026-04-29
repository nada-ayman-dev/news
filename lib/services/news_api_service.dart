import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:news/model/home/news_article.dart';

class NewsApiService {
  static const String apiKey = '0df7ec81584647518dd94c374ff7b165';
  static const String baseUrl = 'https://newsapi.org/v2';

  // Map category names to NewsAPI categories
  static const Map<String, String> categoryMap = {
    'General': 'general',
    'Business': 'business',
    'Sports': 'sports',
    'Technology': 'technology',
    'Entertainment': 'entertainment',
    'Health': 'health',
    'Science': 'science',
  };

  static Future<List<NewsArticle>> fetchArticlesByCategory(
    String category,
  ) async {
    try {
      final String categoryValue = categoryMap[category] ?? 'general';
      final String url =
          '$baseUrl/top-headlines?category=$categoryValue&apiKey=$apiKey&pageSize=10&page=1';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final articles = json['articles'] as List;

        return articles
            .map(
              (article) => NewsArticle(
                id: article['url'] ?? '',
                category: category,
                title: article['title'] ?? 'No Title',
                description: article['description'] ?? 'No Description',
                imagePath: article['urlToImage'] ?? '',
                publishedDate: DateTime.parse(
                  article['publishedAt'] ?? DateTime.now().toString(),
                ),
                author:
                    article['author'] ?? article['source']['name'] ?? 'Unknown',
                content: article['content'] ?? '',
                url: article['url'] ?? '',
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<NewsArticle>> searchArticles(String query) async {
    try {
      final String url =
          '$baseUrl/everything?q=$query&sortBy=popularity&apiKey=$apiKey&pageSize=20&page=1';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final articles = json['articles'] as List;

        return articles
            .map(
              (article) => NewsArticle(
                id: article['url'] ?? '',
                category: 'Search',
                title: article['title'] ?? 'No Title',
                description: article['description'] ?? 'No Description',
                imagePath: article['urlToImage'] ?? '',
                publishedDate: DateTime.parse(
                  article['publishedAt'] ?? DateTime.now().toString(),
                ),
                author:
                    article['author'] ?? article['source']['name'] ?? 'Unknown',
                content: article['content'] ?? '',
                url: article['url'] ?? '',
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to search articles');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> fetchSources() async {
    try {
      final String url = '$baseUrl/top-headlines/sources?apiKey=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final sources = json['sources'] as List;

        return sources.map((source) => source['name'] as String).toList();
      } else {
        throw Exception('Failed to load sources');
      }
    } catch (e) {
      rethrow;
    }
  }
}
