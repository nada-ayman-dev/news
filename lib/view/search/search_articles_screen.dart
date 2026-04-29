import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news/model/home/news_article.dart';
import 'package:news/model/home/news_source.dart';
import 'package:news/services/news_api_service.dart';
import 'package:news/view/article/article_detail_screen.dart';
import 'package:news/providers/language_provider.dart';
import 'package:news/providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SearchArticlesScreen extends StatefulWidget {
  const SearchArticlesScreen({super.key});

  @override
  State<SearchArticlesScreen> createState() => _SearchArticlesScreenState();
}

class _SearchArticlesScreenState extends State<SearchArticlesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<NewsArticle>>? _futureArticles;
  Future<List<NewsSource>>? _futureSources;
  String? _selectedSourceId;
  String _lastQuery = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();

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

  List<NewsArticle> _filterArticlesBySource(
    List<NewsArticle> articles,
    String? sourceName,
  ) {
    if (sourceName == null) return articles;
    return articles.where((article) => article.author == sourceName).toList();
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
      _selectedSourceId = null;
    });
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
          : FutureBuilder<List<dynamic>>(
              future: Future.wait([
                _futureArticles!,
                _futureSources ?? NewsApiService.fetchSources(),
              ]),
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
                } else if (!snapshot.hasData ||
                    snapshot.data!.isEmpty ||
                    (snapshot.data![0] as List<NewsArticle>).isEmpty) {
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

                final articles = snapshot.data![0] as List<NewsArticle>;
                final sources = snapshot.data![1] as List<NewsSource>;
                final selectedSourceName = sources
                    .firstWhere(
                      (s) => s.id == _selectedSourceId,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: FilterChip(
                                label: const Text('All'),
                                selected: _selectedSourceId == null,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSourceId = null;
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.black87,
                                labelStyle: TextStyle(
                                  color: _selectedSourceId == null
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
                                child: Tooltip(
                                  message: source.description,
                                  child: FilterChip(
                                    label: Text(
                                      source.name.length > 20
                                          ? '${source.name.substring(0, 20)}...'
                                          : source.name,
                                    ),
                                    selected: _selectedSourceId == source.id,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedSourceId = selected
                                            ? source.id
                                            : null;
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    selectedColor: Colors.black87,
                                    labelStyle: TextStyle(
                                      color: _selectedSourceId == source.id
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
