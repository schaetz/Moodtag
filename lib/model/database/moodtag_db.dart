import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'transformers/artists_with_tag_transformer.dart';

part 'moodtag_db.g.dart';

@DriftDatabase(include: {'queries.drift'})
class MoodtagDB extends _$MoodtagDB {
  MoodtagDB() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  final joinTagsForArtist = (MoodtagDB db) => [
        leftOuterJoin(db.assignedTags,
            db.assignedTags.artist.equalsExp(db.artists.id) & db.assignedTags.tag.equalsExp(db.tags.id)),
        innerJoin(db.tags, db.assignedTags.tag.equalsExp(db.tags.id)),
      ];

  //
  // GET
  //
  Stream<List<Artist>> getArtists() {
    return (select(artists)..orderBy([(a) => OrderingTerm.asc(a.orderingName)])).watch();
  }

  Future<List<Artist>> getArtistsOnce() {
    return (select(artists)..orderBy([(a) => OrderingTerm.asc(a.orderingName)])).get();
  }

  Stream<List<ArtistData>> getArtistsWithTags(Set<Tag> filterTags) {
    final query = select(artists).join(joinTagsForArtist(this))..orderBy([OrderingTerm.asc(artists.orderingName)]);
    final typedResultStream = query.watch();
    return typedResultStream.transform(ArtistsWithTagTransformer<ArtistsList>(this, filterTags: filterTags));
  }

  Stream<List<ArtistWithTagFlag>> getArtistsWithTagFlag(int tagId) {
    final tagFlagForArtistExpr = assignedTags.tag.isNotNull();

    final query = select(artists).join([
      leftOuterJoin(assignedTags, assignedTags.artist.equalsExp(artists.id) & assignedTags.tag.equals(tagId),
          useColumns: false),
    ])
      ..addColumns([tagFlagForArtistExpr])
      ..orderBy([OrderingTerm.asc(artists.orderingName)]);
    final typedResultStream = query.watch();
    return _mapArtistsWithTagFlagStream(tagFlagForArtistExpr, typedResultStream, tagId);
  }

  Stream<List<ArtistWithTagFlag>> _mapArtistsWithTagFlagStream(
      Expression tagFlagForArtistExpr, Stream<List<TypedResult>> typedResultStream, int tagId) {
    return typedResultStream.map((r) => r.map((row) {
          return ArtistWithTagFlag(
            row.readTable(artists),
            tagId,
            row.read(tagFlagForArtistExpr) == true,
          );
        }).toList());
  }

  Stream<Artist?> getArtistById(int artistId) {
    return (select(artists)..where((a) => a.id.equals(artistId))).watchSingleOrNull();
  }

  Future<Artist?> getArtistByIdOnce(int artistId) {
    return (select(artists)..where((a) => a.id.equals(artistId))).getSingleOrNull();
  }

  Stream<ArtistData?> getArtistWithTagsById(int artistId) {
    final query = select(artists).join(joinTagsForArtist(this))..where(artists.id.equals(artistId));
    final typedResultStream = query.watch();
    return typedResultStream.transform(ArtistsWithTagTransformer<ArtistData?>(this));
  }

  Future<Artist?> getArtistByNameOnce(String artistName) {
    return (select(artists)..where((a) => a.name.equals(artistName))).getSingleOrNull();
  }

  Stream<List<Tag>> getTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<List<Tag>> getTagsOnce() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Stream<List<TagData>> getTagsWithArtistFreq() {
    final query = select(tags).join([
      leftOuterJoin(assignedTags, tags.id.equalsExp(assignedTags.tag)),
    ])
      ..addColumns([assignedTags.artist.count()])
      ..groupBy([tags.id])
      ..orderBy([OrderingTerm.asc(tags.name)]);
    final typedResultStream = query.watch();
    return _mapTagsWithArtistFreqStream(typedResultStream);
  }

  Stream<List<TagData>> _mapTagsWithArtistFreqStream(Stream<List<TypedResult>> typedResultStream) {
    return typedResultStream.map((r) => r.map((row) {
          return TagData(
            row.readTable(tags),
            row.read(assignedTags.artist.count()),
          );
        }).toList());
  }

  Stream<Tag?> getTagById(int tagId) {
    return (select(tags)..where((t) => t.id.equals(tagId))).watchSingleOrNull();
  }

  Future<Tag?> getTagByIdOnce(int tagId) {
    return (select(tags)..where((t) => t.id.equals(tagId))).getSingleOrNull();
  }

  Future<Tag?> getTagByNameOnce(String tagName) {
    return (select(tags)..where((t) => t.name.equals(tagName))).getSingleOrNull();
  }

  Stream<UserProperty?> getUserProperty(String propertyKey) {
    return (select(userProperties)..where((t) => t.propKey.equals(propertyKey))).watchSingleOrNull();
  }

  Future<UserProperty?> getUserPropertyOnce(String propertyKey) {
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
