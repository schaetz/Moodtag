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
  Stream<List<AssignedTag>> get allArtistTagPairs => select(assignedTags).watch();


  //
  // GET
  //
  Future<Artist> getArtistById(int artistId) {
    return (select(artists)..where((t) => t.id.equals(artistId))).getSingleOrNull();
  }

  Future<Tag> getTagById(int tagId) {
    return (select(tags)..where((t) => t.id.equals(tagId))).getSingleOrNull();
  }


  //
  // CREATE
  //
  Future<int> createArtist(ArtistsCompanion artist) {
    return into(artists).insert(artist);
  }

  Future<int> createTag(TagsCompanion tag) {
    return into(tags).insert(tag);
  }

  Future<int> assignTagToArtist(AssignedTagsCompanion artistTagPair) {
    return into(assignedTags).insert(artistTagPair);
  }


  //
  // DELETE
  //
  Future deleteArtistById(int artistId) {
    return Future.wait([
      (delete(artists)..where((a) => a.id.equals(artistId))).go(),
      (delete(assignedTags)..where((row) => row.artist.equals(artistId))).go()
    ]);
  }

  Future deleteTagById(int tagId) {
    return Future.wait([
      (delete(tags)..where((t) => t.id.equals(tagId))).go(),
      (delete(assignedTags)..where((row) => row.tag.equals(tagId))).go()
    ]);
  }

  Future removeTagFromArtist(int artistId, int tagId) {
    return (delete(assignedTags)..where((row) =>
        row.artist.equals(artistId)
        & row.tag.equals(tagId)
    )).go();
  }

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
  });
}