import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/tag.dart';

final String tableArtists = 'artists';
final String tableTags = 'tags';
final String columnId = '_id';
final String columnArtistName = 'name';
final String columnTagName = 'tag';

class DatabaseConnector {

  static final databaseName = 'MoodtagLibrary.db';
  static final databaseVersion = 1;

  static final DatabaseConnector _instance = DatabaseConnector._privateConstructor();

  static get instance {
    return _instance;
  }

  DatabaseConnector._privateConstructor();


  static Database _database;
  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);

    return await openDatabase(path,
      version: databaseVersion,
      onCreate: _onCreate
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableArtists (
        $columnId INTEGER PRIMARY KEY,
        $columnArtistName VARCHAR(255) NOT NULL
      );
      CREATE TABLE $tableTags (
        $columnId INTEGER PRIMARY KEY,
        $columnTagName VARCHAR(255) NOT NULL
      );
    ''');
  }

  Future<int> insertArtist(Artist artist) async {
    Database db = await _database;
    //int id = await db.insert(tableArtists, artist.toMap()); TODO
  }

  Future<int> insertTag(Tag tag) async {
    Database db = await _database;
    //int id = await db.insert(tableArtists, tag.toMap()); TODO
  }

}
