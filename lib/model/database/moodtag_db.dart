import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:moodtag/model/repository/helpers/dto.dart';
import 'package:moodtag/shared/exceptions/user_readable/database_error.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'transformers/artists_dto_transformer.dart';

part 'moodtag_db.g.dart';

@DriftDatabase(tables: [Artists, Tags, TagCategories, AssignedTags, LastFmAccounts])
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

  final joinTagCategoriesForTag = (MoodtagDB db) => [
        leftOuterJoin(db.tagCategories, db.tagCategories.id.equalsExp(db.tags.category)),
      ];

  //
  // GET
  //

  // GET Artists

  Stream<List<ArtistWithTagsDTO>> getArtists(Set<int> filterTagIds, {String? searchItem = null}) {
    final JoinedSelectStatement query = select(artists).join(joinTagsForArtist(this));
    if (searchItem != null && searchItem.isNotEmpty) {
      query..where(artists.name.like('$searchItem%') | artists.name.like('the $searchItem%'));
    }
    query..orderBy([OrderingTerm.asc(artists.orderingName)]);
    final typedResultStream = query.watch();
    return typedResultStream
        .transform(ArtistsDtoTransformer<List<ArtistWithTagsDTO>>(this, filterTagIds: filterTagIds));
  }

  Stream<ArtistWithTagsDTO?> getArtistById(int artistId) {
    final query = select(artists).join(joinTagsForArtist(this))..where(artists.id.equals(artistId));
    final typedResultStream = query.watch();
    return typedResultStream.transform(ArtistsDtoTransformer<ArtistWithTagsDTO?>(this));
  }

  Future<List<ArtistDataClass>> getBaseArtistsOnce() {
    return (select(artists)..orderBy([(a) => OrderingTerm.asc(a.orderingName)])).get();
  }

  Future<List<ArtistDataClass>> getLatestBaseArtistsOnce(int number) {
    return (select(artists)
          ..orderBy([(a) => OrderingTerm.desc(a.id)])
          ..limit(number))
        .get();
  }

  Future<List<ArtistDataClass>> getBaseArtistsWithIdAboveOnce(int idThreshold) {
    return (select(artists)
          ..where((artist) => artist.id.isBiggerThanValue(idThreshold))
          ..orderBy([(a) => OrderingTerm.asc(a.id)]))
        .get();
  }

  Future<ArtistDataClass?> getBaseArtistByIdOnce(int artistId) {
    return (select(artists)..where((a) => a.id.equals(artistId))).getSingleOrNull();
  }

  // GET Tags

  Stream<List<TagWithDataDTO>> getTags({String? searchItem = null, int? tagCategoryId}) {
    final query = select(tags).join(joinAssignedTagsForTag(this)).join(joinTagCategoriesForTag(this))
      ..addColumns([assignedTags.artist.count()]);

    if (searchItem != null && searchItem.isNotEmpty) {
      query..where(tags.name.like('$searchItem%'));
    }
    if (tagCategoryId != null) {
      query..where(tags.category.equals(tagCategoryId));
    }
    query
      ..groupBy([tags.id])
      ..orderBy([OrderingTerm.asc(tags.name)]);

    final typedResultStream = query.watch();
    return typedResultStream.map((r) => r.map(_mapTagQueryResultsToDto).toList());
  }

  Stream<TagWithDataDTO?> getTagById(int tagId) {
    final query = select(tags).join(joinAssignedTagsForTag(this)).join(joinTagCategoriesForTag(this))
      ..addColumns([assignedTags.artist.count()])
      ..groupBy([tags.id])
      ..where(tags.id.equals(tagId));
    return query.map(_mapTagQueryResultsToDto).watchSingleOrNull();
  }

  Future<List<TagDataClass>> getBaseTagsOnce({Set<int>? filterArtistIds}) {
    final query = select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (filterArtistIds != null) {
      final filterArtistsIds = filterArtistIds.toSet();
      final queryWithJoin = query.join(joinArtistsForTag(this))..where(artists.id.isIn(filterArtistsIds));
      return queryWithJoin.map((row) => row.readTable(tags)).get();
    }
    return query.get();
  }

  Future<List<TagDataClass>> getLatestBaseTagsOnce(int number) {
    return (select(tags)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(number))
        .get();
  }

  Future<TagDataClass?> getBaseTagByIdOnce(int tagId) {
    return (select(tags)..where((t) => t.id.equals(tagId))).getSingleOrNull();
  }

  TagWithDataDTO _mapTagQueryResultsToDto(TypedResult row) {
    final frequency = row.read(assignedTags.artist.count());
    if (frequency == null) {
      throw new DatabaseError('The tag frequency could not be read from the database.');
    }
    return TagWithDataDTO(tag: row.readTable(tags), category: row.readTable(tagCategories), frequency: frequency);
  }

  // GET Tag categories

  Stream<List<TagCategoryDataClass>> getTagCategories() {
    return select(tagCategories).watch();
  }

  Future<List<TagCategoryDataClass>> getTagCategoriesOnce() {
    return select(tagCategories).get();
  }

  Future<TagCategoryDataClass?> getTagCategoryByIdOnce(int categoryId) {
    return (select(tagCategories)..where((c) => c.id.equals(categoryId))).getSingleOrNull();
  }

  Future<TagCategoryDataClass?> getDefaultTagCategoryOnce({int? excludeId}) {
    final selectStatement = select(tagCategories);
    if (excludeId != null) {
      selectStatement..where((row) => row.id.equals(excludeId).not());
    }
    return (selectStatement
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  // GET LastFmAccount

  Stream<LastFmAccountDataClass?> getLastFmAccount() {
    return select(lastFmAccounts).watchSingleOrNull();
  }

  Future<LastFmAccountDataClass?> getLastFmAccountOnce() {
    return select(lastFmAccounts).getSingleOrNull();
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

  Future<void> createTagsInBatch(List<TagsCompanion> tagsList) async {
    await batch((batch) {
      batch.insertAll(tags, tagsList, onConflict: DoNothing(target: [tags.name]));
    });
  }

  Future<int> assignTagToArtist(AssignedTagsCompanion artistTagPair) {
    return into(assignedTags).insert(artistTagPair);
  }

  Future<void> assignTagsToArtistsInBatch(List<AssignedTagsCompanion> artistTagPairsList) async {
    await batch((batch) {
      batch.insertAll(assignedTags, artistTagPairsList,
          onConflict: DoNothing(target: [assignedTags.artist, assignedTags.tag]));
    });
  }

  Future<int> createTagCategory(TagCategoriesCompanion tagCategory) {
    return into(tagCategories).insert(tagCategory);
  }

  Future<int> createOrUpdateLastFmAccount(LastFmAccountsCompanion lastFmAccount) {
    return into(lastFmAccounts).insertOnConflictUpdate(lastFmAccount);
  }

  //
  // UPDATE
  //
  Future<int> changeCategoryForTag(int tagId, int tagCategoryId) {
    return (update(tags)..where((row) => row.id.equals(tagId))).write(TagsCompanion(category: Value(tagCategoryId)));
  }

  Future<int> updateTagCategory(int categoryId, TagCategoriesCompanion newValues) {
    return (update(tagCategories)..where((row) => row.id.equals(categoryId))).write(newValues);
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

  Future deleteTagCategoryById(int deletedCategoryId, int insertedCategoryId) {
    return Future.wait([
      (update(tags)..where((row) => row.category.equals(deletedCategoryId)))
          .write(TagsCompanion(category: Value(insertedCategoryId))),
      (delete(tagCategories)..where((c) => c.id.equals(deletedCategoryId))).go()
    ]);
  }

  Future deleteAllArtists() {
    return delete(artists).go();
  }

  Future deleteAllTags() async {
    await deleteAllAssignedTags(); // Assigned tags cannot exist without tags
    return delete(tags).go();
  }

  Future deleteAllAssignedTags() {
    return delete(assignedTags).go();
  }

  Future deleteAllTagCategories() async {
    await deleteAllTags(); // Tags cannot exist without tag categories
    return delete(tagCategories).go();
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
