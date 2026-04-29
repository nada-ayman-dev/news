import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:news/providers/language_provider.dart';
import 'package:news/providers/theme_provider.dart';
import 'package:news/view/category/category_articles_screen.dart';
import 'package:news/view/search/search_articles_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryArticlesScreen(category: category),
      ),
    );
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
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(
              languageProvider.isArabic ? 'الرئيسية' : 'Home',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            );
          },
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
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 1, color: Colors.grey.shade300),
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 40,
                ),
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
                onTap: () => Navigator.pop(context),
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
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text('العربية'),
                            ),
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
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Good Morning Section
              const Text(
                'Good Morning',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Here is Some News For You',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // General News Card
              NewsCard(
                category: 'General',
                imagePath: 'assets/svgimages/general.svg',
                isImageLeft: true,

                onTap: () => _navigateToCategory('General'),
              ),
              const SizedBox(height: 16),

              // Business News Card
              NewsCard(
                category: 'Business',
                imagePath: 'assets/svgimages/business.svg',
                isImageLeft: false,
                onTap: () => _navigateToCategory('Business'),
              ),
              const SizedBox(height: 16),

              // Sports News Card
              NewsCard(
                category: 'Sports',
                imagePath: 'assets/svgimages/sports.svg',
                isImageLeft: true,
                onTap: () => _navigateToCategory('Sports'),
              ),
              const SizedBox(height: 16),

              // Technology News Card
              NewsCard(
                category: 'Technology',
                imagePath: 'assets/svgimages/technology.svg',
                isImageLeft: false,
                onTap: () => _navigateToCategory('Technology'),
              ),
              const SizedBox(height: 16),

              // Entertainment News Card
              NewsCard(
                category: 'Entertainment',
                imagePath: 'assets/svgimages/entertainment.svg',
                isImageLeft: true,
                onTap: () => _navigateToCategory('Entertainment'),
              ),
              const SizedBox(height: 16),

              // Health News Card
              NewsCard(
                category: 'Health',
                imagePath: 'assets/svgimages/health.svg',
                isImageLeft: false,
                onTap: () => _navigateToCategory('Health'),
              ),
              const SizedBox(height: 16),

              // Science News Card
              NewsCard(
                category: 'Science',
                imagePath: 'assets/svgimages/science.svg',
                isImageLeft: true,
                onTap: () => _navigateToCategory('Science'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// News Category Card Widget
class NewsCard extends StatelessWidget {
  final String category;
  final String imagePath;
  final bool isImageLeft;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.category,
    required this.imagePath,
    required this.isImageLeft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: 0,
        child: Opacity(
          opacity: 1,
          child: Container(
            width: 363,
            height: 198,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: isImageLeft
                    ? [
                        // Image on the left
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SvgPicture.asset(
                              imagePath,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Category and button on the right
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: onTap,
                                icon: const Icon(Icons.arrow_forward, size: 18),
                                label: const Text('View All'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : [
                        // Category and button on the left
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: onTap,
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: const Text('View All'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Image on the right
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SvgPicture.asset(
                              imagePath,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
