import 'package:flutter/material.dart';
import 'package:news/model/home/news_article.dart';
import 'package:news/services/news_api_service.dart';
import 'package:news/view/article/article_detail_screen.dart';
import 'package:intl/intl.dart';

class SearchArticlesScreen extends StatefulWidget {
  const SearchArticlesScreen({super.key});

  @override
  State<SearchArticlesScreen> createState() => _SearchArticlesScreenState();
}

class _SearchArticlesScreenState extends State<SearchArticlesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<NewsArticle>>? _futureArticles;
  String? _selectedSource;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<String> _extractSources(List<NewsArticle> articles) {
    final sources = <String>{};
    for (var article in articles) {
      sources.add(article.author);
    }
    return sources.toList();
  }

  List<NewsArticle> _filterArticlesBySource(
    List<NewsArticle> articles,
    String? source,
  ) {
    if (source == null) return articles;
    return articles.where((article) => article.author == source).toList();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _futureArticles = null;
      });
      return;
    }

    setState(() {
      _futureArticles = NewsApiService.searchArticles(query);
      _lastQuery = query;
      _selectedSource = null;
    });
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
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) {
              // Debounce search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (value.isNotEmpty && _searchController.text == value) {
                  _performSearch(value);
                }
              });
            },
            onSubmitted: _performSearch,
            decoration: InputDecoration(
              hintText: 'Search articles...',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.grey.shade700,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _futureArticles = null;
                        });
                      },
                    )
                  : null,
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: _futureArticles == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Search for articles',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : FutureBuilder<List<NewsArticle>>(
              future: _futureArticles,
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
                          'Error searching articles',
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No articles found for "$_lastQuery"',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final articles = snapshot.data!;
                final sources = _extractSources(articles);
                final filteredArticles = _filterArticlesBySource(
                  articles,
                  _selectedSource,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: FilterChip(
                                label: const Text('All'),
                                selected: _selectedSource == null,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSource = null;
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.black87,
                                labelStyle: TextStyle(
                                  color: _selectedSource == null
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            // Individual source chips
                            ...sources.map((source) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: FilterChip(
                                  label: Text(
                                    source.length > 20
                                        ? '${source.substring(0, 20)}...'
                                        : source,
                                  ),
                                  selected: _selectedSource == source,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSource = selected
                                          ? source
                                          : null;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: Colors.black87,
                                  labelStyle: TextStyle(
                                    color: _selectedSource == source
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
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
                                          errorBuilder:
                                              (context, error, stackTrace) {
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                _getTimeAgo(
                                                  article.publishedDate,
                                                ),
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
