import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'moodtag_db.g.dart';


@DriftDatabase(
  tables: [Artists, Tags, AssignedTags],
  include: {'queries.drift'}
)
class MoodtagDB extends _$MoodtagDB {

  MoodtagDB() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Artist>> get allArtists => select(artists).watch();
  Future<List<Tag>> get allTags => select(tags).get();

  Future<Artist> getArtistById(int artistId) {
    return (select(artists)..where((t) => t.id.equals(artistId))).getSingleOrNull();
  }

  Future<Tag> getTagById(int tagId) {
    return (select(tags)..where((t) => t.id.equals(tagId))).getSingleOrNull();
  }


  Future<int> createArtist(ArtistsCompanion artist) {
    return into(artists).insert(artist);
  }
  Future<int> createTag(TagsCompanion tag) {
    return into(tags).insert(tag);
  }
  Future<int> assignTagToArtist(AssignedTagsCompanion artistTagPair) {
    return into(assignedTags).insert(artistTagPair);
  }

  Future<int> deleteArtistById(int artistId) {
    return (delete(artists)..where((a) => a.id.equals(artistId))).go();
  }
  Future<int> deleteArtistByName(String name) {
    return (delete(artists)..where((a) => a.name.equals(name))).go();
  }
  Future<int> deleteTagById(int tagId) {
    return (delete(tags)..where((t) => t.id.equals(tagId))).go();
  }
  Future<int> deleteTagByName(String name) {
    return (delete(tags)..where((t) => t.name.equals(name))).go();
  }

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
  });
}