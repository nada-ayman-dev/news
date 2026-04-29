class NewsArticle {
  final String id;
  final String category;
  final String title;
  final String description;
  final String imagePath;
  final DateTime publishedDate;
  final String author;
  final String content;
  final String url;

  NewsArticle({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.publishedDate,
    required this.author,
    this.content = '',
    this.url = '',
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['imagePath'] ?? '',
      publishedDate: DateTime.parse(
        json['publishedDate'] ?? DateTime.now().toString(),
      ),
      author: json['author'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'publishedDate': publishedDate.toIso8601String(),
      'author': author,
      'content': content,
      'url': url,
    };
  }
}
