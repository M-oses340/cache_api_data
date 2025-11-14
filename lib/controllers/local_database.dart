import 'package:sqflite/sqflite.dart';
class LocalDatabase{
  static Future<Database> createDatabase()async{
    return await openDatabase(
      "hacker_news.db",
      version: 1,
      onCreate: (db, version)async{
        await db.execute(
            'CREATE TABLE news (id INTEGER PRIMARY KEY,title TEXT,url TEXT,author VARCHAR(255), updatedAt TEXT');

      },
    );
  }

}