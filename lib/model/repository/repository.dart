import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/helpers/entity_converter.dart';
import 'package:moodtag/model/repository/helpers/repository_helper.dart';
import 'package:moodtag/model/repository/library_subscription/repository_mixin/library_subscription_manager.dart';
import 'package:moodtag/shared/exceptions/db_request_response.dart';
import 'package:moodtag/shared/exceptions/user_readable/database_error.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_artist.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/shared/models/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/shared/utils/helpers.dart';

import '../database/moodtag_db.dart';

class Repository with LibrarySubscriptionManager {
  final MoodtagDB db;
  late final RepositoryHelper helper;
  late final EntityConverter converter;

  Repository() : db = MoodtagDB() {
    helper = RepositoryHelper(this);
    converter = EntityConverter();
    initializeLibraryIfNecessary();
  }

  void close() {
    cancelAllStreamSubscriptions();
    db.close();
  }

  Future initializeLibraryIfNecessary() async {
    List<TagCategory> tagCategories = await getTagCategoriesOnce();
    if (tagCategories.isEmpty) {
      _initializeLibrary();
    }
  }

  Future _initializeLibrary() async {
    await createTagCategory('Genre', color: Colors.blue.value);
    await createTagCategory('Mood', color: Colors.green.value);
    await createTagCategory('Source', color: Colors.yellow.value);
  }

  Future resetLibrary() async {
    await deleteAllTags();
    await deleteAllArtists();
    await deleteAllTagCategories();
    await _initializeLibrary();
  }

  //
  // Artists
  //
  Stream<List<Artist>> getArtists({Set<int> filterTagIds = const {}, String? searchItem = null}) {
    return db.getArtists(filterTagIds, searchItem: searchItem).map(converter.createArtistsListFromDTOs);
  }

  Stream<List<Artist>> getArtistsHavingTag(Tag tag) {
    return getArtists(filterTagIds: {tag.id});
  }

  Stream<Artist?> getArtistById(int artistId) {
    return db.getArtistById(artistId).map(converter.createArtistFromOptionalDTO);
  }

  Future<List<Artist>> getArtistsOnce({Set<int> filterTagIds = const {}, String? searchItem = null}) {
    return getArtists(filterTagIds: filterTagIds, searchItem: searchItem).first;
  }

  Future<List<BaseArtist>> getBaseArtistsOnce() {
    return db
        .getBaseArtistsOnce()
        .then((dataClassList) => converter.createBaseArtistsListFromDataClasses(dataClassList));
  }

  Future<List<BaseArtist>> getLatestBaseArtistsOnce(int number) {
    return db
        .getLatestBaseArtistsOnce(number)
        .then((dataClassList) => converter.createBaseArtistsListFromDataClasses(dataClassList));
  }

  Future<BaseArtist?> getBaseArtistByIdOnce(int id) {
    return db
        .getBaseArtistByIdOnce(id)
        .then((dataClass) => dataClass != null ? converter.createBaseArtistFromDataClass(dataClass) : null);
  }

  Future<bool> doesArtistHaveTag(BaseArtist artist, BaseTag tag) async {
    final List<BaseTag> tagsWithArtist = await getBaseTagsOnce(filterArtistIds: {artist.id});
    final tagIDs = tagsWithArtist.map((tag) => tag.id).toSet();
    return tagIDs.contains(tag.id);
  }

  Future<Set<String>> getSetOfExistingArtistNames() async {
    final allArtists = await db.getBaseArtistsOnce();
    return allArtists.map((artist) => artist.name).toSet();
  }

  Future<DbRequestResponse<BaseArtist>> createArtist(String name, {String? spotifyId}) async {
    Future<int> createArtistFuture = db.createArtist(
        ArtistsCompanion.insert(name: name, orderingName: getOrderingNameForArtist(name), spotifyId: Value(spotifyId)));
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<BaseArtist>(createArtistFuture, name);
  }

  Future<void> createImportedArtistsInBatch(List<ImportedArtist> importedArtists) async {
    await db.createArtistsInBatch(List.from(importedArtists.map((artist) => ArtistsCompanion.insert(
        name: artist.name,
        orderingName: getOrderingNameForArtist(artist.name),
        spotifyId: Value(artist is SpotifyArtist ? artist.spotifyId : null)))));
  }

  Future<DbRequestResponse> deleteArtist(BaseArtist artist) async {
    Future deleteArtistFuture = db.deleteArtistById(artist.id);
    return helper.wrapExceptionsAndReturnResponse(deleteArtistFuture);
  }

  Future deleteAllArtists() {
    return db.deleteAllArtists();
  }

  //
  // Tags
  //
  Stream<List<Tag>> getTags({String? searchItem = null}) {
    return db.getTags(searchItem: searchItem).map(converter.createTagsListFromDTOs);
  }

  Stream<List<Tag>> getTagsWithCategory(TagCategory tagCategory) {
    return db.getTags(tagCategoryId: tagCategory.id).map(converter.createTagsListFromDTOs);
  }

  Stream<Tag?> getTagById(int id) {
    return db.getTagById(id).map(converter.createTagFromOptionalDTO);
  }

  Future<List<Tag>> getTagsOnce({String? searchItem = null}) {
    return getTags(searchItem: searchItem).first;
  }

  Future<List<BaseTag>> getBaseTagsOnce({Set<int>? filterArtistIds}) {
    return db
        .getBaseTagsOnce(filterArtistIds: filterArtistIds)
        .then((dataClassList) => converter.createBaseTagsListFromDataClasses(dataClassList));
  }

  Future<List<BaseTag>> getLatestBaseTagsOnce(int number) {
    return db
        .getLatestBaseTagsOnce(number)
        .then((dataClassList) => converter.createBaseTagsListFromDataClasses(dataClassList));
  }

  Future<BaseTag?> getBaseTagByIdOnce(int id) {
    return db
        .getBaseTagByIdOnce(id)
        .then((dataClass) => dataClass != null ? converter.createBaseTagFromDataClass(dataClass) : null);
  }

  Future<Set<String>> getSetOfExistingTagNames() async {
    final allBaseTags = await getBaseTagsOnce();
    return allBaseTags.map((tag) => tag.name).toSet();
  }

  Future<DbRequestResponse<BaseTag>> createTag(String name, TagCategory tagCategory) {
    Future<int> createTagFuture = db.createTag(TagsCompanion.insert(name: name, category: tagCategory.id));
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<BaseTag>(createTagFuture, name);
  }

  Future<void> createImportedTagsInBatch(List<ImportedTag> importedTags) async {
    await db.createTagsInBatch(
        List.from(importedTags.map((tag) => TagsCompanion.insert(name: tag.name, category: tag.category.id))));
  }

  Future<DbRequestResponse> changeCategoryForTag(Tag tag, TagCategory tagCategory) async {
    Future<int> changeCategoryForTagFuture = db.changeCategoryForTag(tag.id, tagCategory.id);
    return helper.wrapExceptionsAndReturnResponse(changeCategoryForTagFuture);
  }

  Future<DbRequestResponse> deleteTag(Tag tag) {
    Future deleteArtistFuture = db.deleteTagById(tag.id);
    return helper.wrapExceptionsAndReturnResponse(deleteArtistFuture);
  }

  Future deleteAllTags() {
    return db.deleteAllTags();
  }

  //
  // Assigned tags
  //
  Future<DbRequestResponse> assignTagToArtist(BaseArtist artist, BaseTag tag) async {
    Future<int> assignTagFuture = db.assignTagToArtist(AssignedTagsCompanion.insert(artist: artist.id, tag: tag.id));
    return helper.wrapExceptionsAndReturnResponse(assignTagFuture);
  }

  Future<void> assignTagsToArtistsInBatch(Map<BaseArtist, List<BaseTag>> tagsForArtistsMap) async {
    await db.assignTagsToArtistsInBatch(tagsForArtistsMap.entries
        .expand((mapEntry) =>
            mapEntry.value.map((tag) => AssignedTagsCompanion.insert(artist: mapEntry.key.id, tag: tag.id)))
        .toList());
  }

  Future<DbRequestResponse> removeTagFromArtist(BaseArtist artist, BaseTag tag) {
    return helper.wrapExceptionsAndReturnResponse(db.removeTagFromArtist(artist.id, tag.id));
  }

  //
  // Tag categories
  //
  Future<DbRequestResponse<TagCategory>> createTagCategory(String name, {required int color}) {
    Future<int> createTagCategoryFuture = db.createTagCategory(TagCategoriesCompanion.insert(name: name, color: color));
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<TagCategory>(createTagCategoryFuture, name);
  }

  Future<DbRequestResponse> editTagCategory(TagCategory tagCategory, {required String name, required int color}) {
    Future<int> updateTagCategoryFuture =
        db.updateTagCategory(tagCategory.id, TagCategoriesCompanion.insert(name: name, color: color));
    return helper.wrapExceptionsAndReturnResponse(updateTagCategoryFuture);
  }

  Stream<List<TagCategory>> getTagCategories() {
    return db.getTagCategories().map(converter.createTagCategoriesListFromDataClasses);
  }

  Future<List<TagCategory>> getTagCategoriesOnce() {
    return db
        .getTagCategoriesOnce()
        .then((dataClassList) => converter.createTagCategoriesListFromDataClasses(dataClassList));
  }

  Future<TagCategory?> getDefaultTagCategoryOnce({int? excludeId}) {
    return db
        .getDefaultTagCategoryOnce(excludeId: excludeId)
        .then((dataClass) => converter.createTagCategoryFromOptionalDataClass(dataClass));
  }

  Future<TagCategory?> getTagCategoryByIdOnce(int id) {
    return db
        .getTagCategoryByIdOnce(id)
        .then((dataClass) => dataClass != null ? converter.createTagCategoryFromDataClass(dataClass) : null);
  }

  /** Deletes a tag category, making sure that it is not the last remaining category
   *  and that there is a replacement for all tags currently using this category */
  Future<DbRequestResponse> removeTagCategory(TagCategory deletedCategory, TagCategory? insertedCategory) async {
    if (insertedCategory == null) {
      insertedCategory = await getDefaultTagCategoryOnce(excludeId: deletedCategory.id);
      if (insertedCategory == null) {
        throw DatabaseError('Tag category "${deletedCategory.name}" can not be removed, as there is no replacement.');
      }
    }

    return await _deleteTagCategory(deletedCategory, insertedCategory);
  }

  /** Deletes a tag category WITHOUT making sure that it is not the last remaining category
   *  and that there is a replacement for all tags currently using this category */
  Future<DbRequestResponse> _deleteTagCategory(TagCategory deletedCategory, TagCategory insertedCategory) {
    Future deleteTagCategoryFuture = db.deleteTagCategoryById(deletedCategory.id, insertedCategory.id);
    return helper.wrapExceptionsAndReturnResponse(deleteTagCategoryFuture);
  }

  Future<DbRequestResponse> deleteAllTagCategories() {
    Future deleteAllTagCategoriesFuture = db.deleteAllTagCategories();
    return helper.wrapExceptionsAndReturnResponse(deleteAllTagCategoriesFuture);
  }

  //
  // Last.fm accounts
  //
  Stream<LastFmAccount?> getLastFmAccount() {
    return db.getLastFmAccount().map(converter.createLastFmAccountFromOptionalDataClass);
  }

  Future<LastFmAccount?> getLastFmAccountOnce() {
    return db.getLastFmAccountOnce().then((dataClass) => converter.createLastFmAccountFromOptionalDataClass(dataClass));
  }

  Future<DbRequestResponse<LastFmAccount>> createOrUpdateLastFmAccount(LastFmAccount lastFmAccount) async {
    await db.deleteAllLastFmAccounts();
    Future<int> createAccountFuture =
        db.createOrUpdateLastFmAccount(converter.convertLastFmAccountToDataClass(lastFmAccount).toCompanion(false));
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<LastFmAccount>(
        createAccountFuture, lastFmAccount.name);
  }

  Future removeLastFmAccount() {
    Future<int> deleteAccountFuture = db.deleteAllLastFmAccounts();
    return helper.wrapExceptionsAndReturnResponse(deleteAccountFuture);
  }
}
