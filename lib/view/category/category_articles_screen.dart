import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news/model/home/news_article.dart';
import 'package:news/model/home/news_source.dart';
import 'package:news/services/news_api_service.dart';
import 'package:news/view/article/article_detail_screen.dart';
import 'package:news/view/search/search_articles_screen.dart';
import 'package:news/providers/language_provider.dart';
import 'package:news/providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class CategoryArticlesScreen extends StatefulWidget {
  final String category;

  const CategoryArticlesScreen({super.key, required this.category});

  @override
  State<CategoryArticlesScreen> createState() => _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState extends State<CategoryArticlesScreen> {
  late Future<List<NewsArticle>> futureArticles;
  late Future<List<NewsSource>> futureSources;
  String? selectedSourceId;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    futureArticles = NewsApiService.fetchArticlesByCategory(widget.category);
    futureSources = NewsApiService.fetchSources(category: widget.category);

    // Real-time timestamp updates every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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

  List<NewsArticle> _filterArticlesBySource(
    List<NewsArticle> articles,
    String? sourceName,
  ) {
    if (sourceName == null) return articles;
    return articles.where((article) => article.author == sourceName).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
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
      drawer: Drawer(
        width: 269,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
              child: Center(
                child: Container(
                  width: 269,
                  height: 166,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'News App',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              title: Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return Row(
                    children: [
                      const Icon(Icons.home, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        languageProvider.isArabic
                            ? 'اذهب للرئيسية'
                            : 'Go To Home',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  );
                },
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Theme',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ThemeMode>(
                        initialValue: themeProvider.themeMode,
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Row(
                              children: [
                                Icon(Icons.dark_mode, size: 18),
                                SizedBox(width: 8),
                                Text('Dark'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Row(
                              children: [
                                Icon(Icons.light_mode, size: 18),
                                SizedBox(width: 8),
                                Text('Light'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Row(
                              children: [
                                Icon(Icons.settings_brightness, size: 18),
                                SizedBox(width: 8),
                                Text('System'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            themeProvider.setThemeMode(mode);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.language, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            languageProvider.isArabic ? 'اللغة' : 'Language',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue:
                            languageProvider.currentLocale.languageCode,
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'ar', child: Text('العربية')),
                        ],
                        onChanged: (lang) {
                          if (lang != null) {
                            languageProvider.setLanguage(lang);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
          final sources = snapshot.data![1] as List<NewsSource>;
          final selectedSourceName = sources
              .firstWhere(
                (s) => s.id == selectedSourceId,
                orElse: () => NewsSource(
                  id: '',
                  name: '',
                  description: '',
                  url: '',
                  category: '',
                  language: '',
                  country: '',
                ),
              )
              .name;
          final filteredArticles = _filterArticlesBySource(
            articles,
            selectedSourceName.isEmpty ? null : selectedSourceName,
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
                          selected: selectedSourceId == null,
                          onSelected: (selected) {
                            setState(() {
                              selectedSourceId = null;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.black87,
                          labelStyle: TextStyle(
                            color: selectedSourceId == null
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      // Individual source chips
                      ...sources.map((source) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Tooltip(
                            message: source.description,
                            child: FilterChip(
                              label: Text(
                                source.name.length > 20
                                    ? '${source.name.substring(0, 20)}...'
                                    : source.name,
                              ),
                              selected: selectedSourceId == source.id,
                              onSelected: (selected) {
                                setState(() {
                                  selectedSourceId = selected
                                      ? source.id
                                      : null;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: Colors.black87,
                              labelStyle: TextStyle(
                                color: selectedSourceId == source.id
                                    ? Colors.white
                                    : Colors.black,
                              ),
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
