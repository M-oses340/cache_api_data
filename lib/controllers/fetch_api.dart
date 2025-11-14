import 'dart:convert';
import 'package:cache_api_data_in_flutter/controllers/local_database.dart';
import 'package:cache_api_data_in_flutter/models/models.dart';
import 'package:http/http.dart' as http;

class HackerNewsApi {
  static Future<bool> getLatestHackerNews(int pageNo) async {
    String url =
        "https://hn.algolia.com/api/v1/search_by_date?tags=story&page=$pageNo";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save each news item in local database
        for (var dt in data["hits"]) {
          final news = HackerNews.fromJson(dt);
          await LocalDatabase.insertNews(news); // ✅ await here
        }

        // Save the last fetched time for this page
        await LocalDatabase.insertSaveTime(pageNo); // ✅ await here

        return true;
      } else {
        print("Error fetching API: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception fetching API: $e");
      return false;
    }
  }
}
