import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'moodtag_db.g.dart';


class Artists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 255)();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 255)();
}

class AssignedTags extends Table {
  IntColumn get artist => integer().customConstraint('NOT NULL REFERENCES artists(id)')();
  IntColumn get tag => integer().customConstraint('NOT NULL REFERENCES tags(id)')();

  @override
  Set<Column> get primaryKey => {artist, tag};
}


@DriftDatabase(tables: [Artists, Tags])
class MoodtagDB extends _$MoodtagDB {

  MoodtagDB() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Artist>> get allArtists => select(artists).watch();
  Future<List<Tag>> get allTags => select(tags).get();

  Future<int> addArtist(ArtistsCompanion artist) {
    return into(artists).insert(artist);
  }
  Future<int> addTag(TagsCompanion tag) {
    return into(tags).insert(tag);
  }

  Future<int> deleteArtist(int artistId) {
    return (delete(artists)..where((a) => a.id.equals(artistId))).go();
  }
  Future<int> deleteTags(int tagId) {
    return (delete(tags)..where((t) => t.id.equals(tagId))).go();
  }


}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
  });
}