import 'package:flutter/material.dart';
import 'package:news/model/home/news_article.dart';
import 'package:news/services/news_api_service.dart';
import 'package:news/view/article/article_detail_screen.dart';
import 'package:news/view/search/search_articles_screen.dart';
import 'package:intl/intl.dart';

class CategoryArticlesScreen extends StatefulWidget {
  final String category;

  const CategoryArticlesScreen({super.key, required this.category});

  @override
  State<CategoryArticlesScreen> createState() => _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState extends State<CategoryArticlesScreen> {
  late Future<List<NewsArticle>> futureArticles;
  late Future<List<String>> futureSources;
  String? selectedSource;

  @override
  void initState() {
    super.initState();
    futureArticles = NewsApiService.fetchArticlesByCategory(widget.category);
    futureSources = NewsApiService.fetchSources();
  }

  String _getTimeAgo(DateTime publishedDate) {
    final Duration difference = DateTime.now().difference(publishedDate);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(publishedDate);
    }
  }

  List<NewsArticle> _filterArticlesBySource(
    List<NewsArticle> articles,
    String? source,
  ) {
    if (source == null) return articles;
    return articles.where((article) => article.author == source).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchArticlesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([futureArticles, futureSources]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading articles',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No articles found',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          final articles = snapshot.data![0] as List<NewsArticle>;
          final availableSources = snapshot.data![1] as List<String>;
          final filteredArticles = _filterArticlesBySource(
            articles,
            selectedSource,
          );

          return Column(
            children: [
              // Sources Bar
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // "All" chip
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: selectedSource == null,
                          onSelected: (selected) {
                            setState(() {
                              selectedSource = null;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.black87,
                          labelStyle: TextStyle(
                            color: selectedSource == null
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      // Individual source chips
                      ...availableSources.map((source) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(
                              source.length > 20
                                  ? '${source.substring(0, 20)}...'
                                  : source,
                            ),
                            selected: selectedSource == source,
                            onSelected: (selected) {
                              setState(() {
                                selectedSource = selected ? source : null;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.black87,
                            labelStyle: TextStyle(
                              color: selectedSource == source
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // Articles List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArticleDetailScreen(article: article),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Article Image
                              if (article.imagePath.isNotEmpty)
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  child: Image.network(
                                    article.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              // Article Content
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      article.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Author and Time
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'By: ${article.author}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _getTimeAgo(article.publishedDate),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
