import 'package:cache_api_data_in_flutter/controllers/fetch_api.dart';
import 'package:cache_api_data_in_flutter/controllers/local_database.dart';
import 'package:cache_api_data_in_flutter/models/models.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();

  List<HackerNews> latestNews = [];
  bool isLoading = true;
  bool isMoreNewsLoading = false;
  List<Map<String, dynamic>> savedTime = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadSavedTime();
    await _loadFirstPageNews();
    _scrollController.addListener(_scrollListener);
  }

  /// Load saved time table
  Future<void> _loadSavedTime() async {
    final time = await LocalDatabase.getSaveTime();
    setState(() => savedTime = time);
  }

  /// Load first page of news
  Future<void> _loadFirstPageNews() async {
    final count = await LocalDatabase.getNewsCount() ?? 0;

    final firstPageTime = savedTime.isNotEmpty
        ? DateTime.parse(savedTime[0]["lastSavedTime"])
        : DateTime(2000);

    final difference = DateTime.now().difference(firstPageTime);

    if (difference.inMinutes > 5 || count == 0) {
      final success = await HackerNewsApi.getLatestHackerNews(0);
      if (success) await _getNews();
    } else {
      await _getNews();
    }
  }

  /// Load next page of news
  Future<void> _loadNextPageNews() async {
    setState(() => isMoreNewsLoading = true);

    final pageTime = currentPage < savedTime.length
        ? DateTime.parse(savedTime[currentPage]["lastSavedTime"])
        : DateTime(2000);

    final difference = DateTime.now().difference(pageTime);

    if (difference.inMinutes > 5) {
      final success = await HackerNewsApi.getLatestHackerNews(currentPage);
      if (success) await _getMoreNews();
    } else {
      await _getMoreNews();
    }
  }

  /// Read first 20 news from database
  Future<void> _getNews() async {
    final news = await LocalDatabase.getNews();
    setState(() {
      latestNews = news.map((e) => HackerNews.fromMap(e)).toList();
      isLoading = false;
    });
  }

  /// Read next 20 news from database
  Future<void> _getMoreNews() async {
    final news = await LocalDatabase.getMoreNews(latestNews.length);
    setState(() {
      latestNews.addAll(news.map((e) => HackerNews.fromMap(e)).toList());
      isMoreNewsLoading = false;
    });
  }

  /// Detect scroll to bottom for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      if (!isMoreNewsLoading) {
        currentPage++;
        _loadNextPageNews();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hacker News"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : latestNews.isEmpty
          ? const Center(child: Text("No News Found"))
          : ListView.builder(
        controller: _scrollController,
        itemCount: latestNews.length,
        itemBuilder: (context, index) {
          final item = latestNews[index];
          return ListTile(
            leading: Text("${index + 1}."),
            title: Text(item.title),
            subtitle: Text("By ${item.author}"),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _launchUrl(item.url),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "refresh",
              onPressed: () async {
                currentPage = 0;
                setState(() => isLoading = true);
                await _loadSavedTime();
                await _loadFirstPageNews();
              },
              child: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              heroTag: "delete",
              onPressed: () async {
                await LocalDatabase.deleteAllNews();
                await LocalDatabase.deleteSavedTime();
                setState(() => latestNews = []);
              },
              child: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMoreNewsLoading
          ? const SizedBox(
          height: 55,
          child: Center(child: CircularProgressIndicator()))
          : null,
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception("Could not launch $url");
    }
  }
}
