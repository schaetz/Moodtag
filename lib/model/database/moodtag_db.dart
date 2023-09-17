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
  MoodtagDB.InMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  final joinTagsForArtist = (MoodtagDB db) => [
        leftOuterJoin(db.assignedTags, db.assignedTags.artist.equalsExp(db.artists.id)),
        leftOuterJoin(db.tags, db.assignedTags.tag.equalsExp(db.tags.id)),
      ];

  final joinAssignedTagsForTag = (MoodtagDB db) => [
        leftOuterJoin(db.assignedTags, db.tags.id.equalsExp(db.assignedTags.tag)),
      ];

  final joinArtistsForTag = (MoodtagDB db) => [
        leftOuterJoin(db.assignedTags, db.assignedTags.tag.equalsExp(db.tags.id)),
        leftOuterJoin(db.artists, db.assignedTags.artist.equalsExp(db.artists.id)),
      ];

  //
  // GET
  //

  // GET Artists

  Stream<List<ArtistData>> getArtistsDataList(Set<Tag> filterTags) {
    final query = select(artists).join(joinTagsForArtist(this))..orderBy([OrderingTerm.asc(artists.orderingName)]);
    final typedResultStream = query.watch();
    return typedResultStream.transform(ArtistsWithTagTransformer<ArtistsList>(this, filterTags: filterTags));
  }

  Stream<ArtistData?> getArtistDataById(int artistId) {
    final query = select(artists).join(joinTagsForArtist(this))..where(artists.id.equals(artistId));
    final typedResultStream = query.watch();
    return typedResultStream.transform(ArtistsWithTagTransformer<ArtistData?>(this));
  }

  Future<List<Artist>> getArtistsOnce() {
    return (select(artists)..orderBy([(a) => OrderingTerm.asc(a.orderingName)])).get();
  }

  Future<Artist?> getArtistByIdOnce(int artistId) {
    return (select(artists)..where((a) => a.id.equals(artistId))).getSingleOrNull();
  }

  // GET Tags

  Stream<List<TagData>> getTagsDataList() {
    final query = select(tags).join(joinAssignedTagsForTag(this))
      ..addColumns([assignedTags.artist.count()])
      ..groupBy([tags.id])
      ..orderBy([OrderingTerm.asc(tags.name)]);
    final typedResultStream = query.watch();
    return typedResultStream.map((r) => r.map(_mapTagWithArtistFreqToTagData).toList());
  }

  Stream<TagData?> getTagDataById(int tagId) {
    final query = select(tags).join(joinAssignedTagsForTag(this))
      ..addColumns([assignedTags.artist.count()])
      ..groupBy([tags.id])
      ..where(tags.id.equals(tagId));
    return query.map(_mapTagWithArtistFreqToTagData).watchSingleOrNull();
  }

  Future<List<Tag>> getTagsOnce({Set<Artist>? filterArtists}) {
    final query = select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (filterArtists != null) {
      final filterArtistsIds = filterArtists.map((artist) => artist.id).toSet();
      final queryWithJoin = query.join(joinArtistsForTag(this))..where(artists.id.isIn(filterArtistsIds));
      return queryWithJoin.map((row) => row.readTable(tags)).get();
    }
    return query.get();
  }

  Future<Tag?> getTagByIdOnce(int tagId) {
    return (select(tags)..where((t) => t.id.equals(tagId))).getSingleOrNull();
  }

  TagData _mapTagWithArtistFreqToTagData(TypedResult row) {
    return TagData(
      row.readTable(tags),
      row.read(assignedTags.artist.count()),
    );
  }

  // GET LastFmAccount

  Stream<LastFmAccount?> getLastFmAccount() {
    return (select(lastFmAccounts)).watchSingleOrNull();
  }

  Future<LastFmAccount?> getLastFmAccountOnce() {
    return (select(lastFmAccounts)).getSingleOrNull();
  }

  //
  // CREATE
  //
  Future<int> createArtist(ArtistsCompanion artist) {
    return into(artists).insert(artist);
  }

  Future<void> createArtistsInBatch(List<ArtistsCompanion> artistsList) async {
    await batch((batch) {
      batch.insertAll(artists, artistsList, onConflict: DoNothing(target: [artists.name]));
    });
  }

  Future<int> createTag(TagsCompanion tag) {
    return into(tags).insert(tag);
  }

  Future<int> assignTagToArtist(AssignedTagsCompanion artistTagPair) {
    return into(assignedTags).insert(artistTagPair);
  }

  Future<int> createOrUpdateLastFmAccount(LastFmAccount lastFmAccount) {
    return into(lastFmAccounts).insertOnConflictUpdate(lastFmAccount);
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

  Future<int> deleteAllLastFmAccounts() {
    return delete(lastFmAccounts).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
