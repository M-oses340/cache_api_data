import 'package:cache_api_data_in_flutter/models/models.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Future<Database> createDatabase() async {
    return await openDatabase(
      "hacker_news.db",
      version: 1,
      onCreate: (db, version) async {
        // Create news table
        await db.execute('''
          CREATE TABLE news (
            id INTEGER PRIMARY KEY,
            title TEXT,
            url TEXT,
            author VARCHAR(255),
            updatedAt TEXT
          )
        ''');

        // Create saved_time table
        await db.execute('''
          CREATE TABLE saved_time (
            page_no INTEGER PRIMARY KEY,
            lastSavedTime TEXT
          )
        ''');
      },
    );
  }

  static Future insertNews(HackerNews hackerNews) async {
    var db = await createDatabase();
    return await db.insert(
      "news",
      {
        "id": hackerNews.id,
        "title": hackerNews.title,
        "url": hackerNews.url,
        "author": hackerNews.author,
        "updatedAt": hackerNews.updatedAt
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getNews() async {
    var db = await createDatabase();
    return await db.query(
      "news",
      orderBy: 'updatedAt DESC',
      limit: 20,
    );
  }

  // ✅ Added method: Get more news with offset for pagination
  static Future<List<Map<String, dynamic>>> getMoreNews(int offset, {int limit = 20}) async {
    var db = await createDatabase();
    return await db.query(
      "news",
      orderBy: 'updatedAt DESC',
      limit: limit,
      offset: offset,
    );
  }

  static Future<int?> getNewsCount() async {
    var db = await createDatabase();
    return Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM news"));
  }

  static Future deleteAllNews() async {
    var db = await createDatabase();
    return await db.delete("news");
  }

  static Future insertSaveTime(int pageNo) async {
    var db = await createDatabase();
    return await db.insert(
      "saved_time",
      {
        "page_no": pageNo,
        "lastSavedTime": DateTime.now().toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getSaveTime() async {
    var db = await createDatabase();
    return await db.query("saved_time");
  }

  static Future deleteSavedTime() async {
    var db = await createDatabase();
    return await db.delete("saved_time");
  }
}
