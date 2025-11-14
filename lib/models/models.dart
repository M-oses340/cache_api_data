class HackerNews {
  final String author;
  final String title;
  final String url;
  final int id;
  final String updatedAt;

  HackerNews({
    required this.id,
    required this.author,
    required this.title,
    required this.url,
    required this.updatedAt,
  });

  /// From API JSON
  factory HackerNews.fromJson(Map<String, dynamic> json) => HackerNews(
    id: json["story_id"] ?? json["id"] ?? 0,
    author: json["author"] ?? "",
    title: json["title"] ?? "",
    url: json["url"] ?? "",
    updatedAt: json["updated_at"] ?? DateTime.now().toString(),
  );

  /// From SQLite Map (DB)
  factory HackerNews.fromMap(Map<String, dynamic> map) => HackerNews(
    id: map["id"] ?? 0,
    author: map["author"] ?? "",
    title: map["title"] ?? "",
    url: map["url"] ?? "",
    updatedAt: map["updatedAt"] ?? DateTime.now().toString(),
  );

  /// To SQLite Map
  Map<String, dynamic> toMap() => {
    "id": id,
    "author": author,
    "title": title,
    "url": url,
    "updatedAt": updatedAt,
  };
}
