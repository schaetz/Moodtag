import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'moodtag_db.g.dart';


@DriftDatabase(
  tables: [Artists, Tags, AssignedTags, UserProperty],
  include: {'queries.drift'}
)
class MoodtagDB extends _$MoodtagDB {

  MoodtagDB() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Artist>> get allArtists => (select(artists)..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  Stream<List<Tag>> get allTags => (select(tags)..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  Stream<List<AssignedTag>> get allArtistTagPairs => select(assignedTags).watch();


  //
  // GET
  //
  Future<Artist> getArtistById(int artistId) {
    return (select(artists)..where((t) => t.id.equals(artistId))).getSingleOrNull();
  }

  Future<Artist> getArtistByName(String artistName) {
    return (select(artists)..where((t) => t.name.equals(artistName))).getSingleOrNull();
  }

  Future<Tag> getTagById(int tagId) {
    return (select(tags)..where((t) => t.id.equals(tagId))).getSingleOrNull();
  }

  Future<Tag> getTagByName(String tagName) {
    return (select(tags)..where((t) => t.name.equals(tagName))).getSingleOrNull();
  }

  Future<UserProperty> getUserProperty(String propertyKey) {
    return (select(userProperties)..where((t) => t.propKey.equals(propertyKey))).getSingleOrNull();
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

  Future<int> createOrUpdateUserProperty(UserPropertiesCompanion userPropertyPair) {
    return into(userProperties).insertOnConflictUpdate(userPropertyPair);
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

  Future deleteAllArtists() {
    return delete(artists).go();
  }

  Future deleteAllTags() {
    return delete(tags).go();
  }

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
  });
}