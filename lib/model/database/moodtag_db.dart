import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'moodtag_db.g.dart';

@DriftDatabase(include: {'queries.drift'})
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
  Stream<List<Artist>> getArtists() {
    return (select(artists)..orderBy([(a) => OrderingTerm.asc(a.orderingName)])).watch();
  }

  Stream<Artist?> getArtistById(int artistId) {
    return (select(artists)..where((t) => t.id.equals(artistId))).getSingleOrNull().asStream();
  }

  Future<Artist?> getArtistByName(String artistName) {
    return (select(artists)..where((t) => t.name.equals(artistName))).getSingleOrNull();
  }

  Stream<List<Tag>> getTags() {
    return (select(tags)..orderBy([(a) => OrderingTerm.asc(a.name)])).watch();
  }

  Stream<List<TagWithArtistFreq>> getTagsWithArtistFreq() {
    final query = select(tags).join([
      leftOuterJoin(assignedTags, tags.id.equalsExp(assignedTags.tag)),
    ])
      ..addColumns([assignedTags.artist.count()])
      ..groupBy([tags.id]);
    final typedResultStream = query.watch();
    return _mapTagsWithArtistFreqStream(typedResultStream);
  }

  Stream<List<TagWithArtistFreq>> _mapTagsWithArtistFreqStream(Stream<List<TypedResult>> typedResultStream) {
    return typedResultStream.map((rows) => rows
        .map((row) => TagWithArtistFreq(
              row.readTable(tags),
              row.read(assignedTags.artist.count()),
            ))
        .toList());
  }

  Stream<Tag?> getTagById(int tagId) {
    return (select(tags)..where((t) => t.id.equals(tagId))).getSingleOrNull().asStream();
  }

  Future<Tag?> getTagByName(String tagName) {
    return (select(tags)..where((t) => t.name.equals(tagName))).getSingleOrNull();
  }

  Future<UserProperty?> getUserProperty(String propertyKey) {
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

  Future deleteUserProperty(String key) {
    return (delete(userProperties)..where((t) => t.propKey.equals(key))).go();
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

  Future<int> removeTagFromArtist(int artistId, int tagId) {
    return (delete(assignedTags)..where((row) => row.artist.equals(artistId) & row.tag.equals(tagId))).go();
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
