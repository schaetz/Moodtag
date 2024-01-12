import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/helpers/repository_helper.dart';
import 'package:moodtag/model/repository/library_subscription/repository_mixin/library_subscription_manager.dart';
import 'package:moodtag/shared/exceptions/db_request_response.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_artist.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/shared/models/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/shared/utils/helpers.dart';

import '../database/moodtag_db.dart';

class Repository with LibrarySubscriptionManager {
  final MoodtagDB db;
  late final RepositoryHelper helper;

  Repository() : db = MoodtagDB() {
    helper = RepositoryHelper(db);
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
  Stream<List<ArtistData>> getArtistsDataList({Set<Tag> filterTags = const {}, String? searchItem = null}) {
    return db.getArtistsDataList(filterTags, searchItem: searchItem);
  }

  Stream<List<ArtistData>> getArtistsDataHavingTag(Tag tag) {
    return getArtistsDataList(filterTags: {tag});
  }

  Stream<ArtistData?> getArtistDataById(int artistId) {
    return db.getArtistDataById(artistId);
  }

  Future<List<Artist>> getArtistsOnce() {
    return db.getArtistsOnce();
  }

  Future<List<Artist>> getLatestArtistsOnce(int number) {
    return db.getLatestArtistsOnce(number);
  }

  Future<bool> doesArtistHaveTag(Artist artist, Tag tag) async {
    final List<Tag> tagsWithArtist = await db.getTagsOnce(filterArtists: {artist});
    return tagsWithArtist.contains(tag);
  }

  Future<Set<String>> getSetOfExistingArtistNames() async {
    final allArtists = await db.getArtistsOnce();
    return allArtists.map((artist) => artist.name).toSet();
  }

  Future<DbRequestResponse<Artist>> createArtist(String name, {String? spotifyId}) async {
    Future<int> createArtistFuture = db.createArtist(
        ArtistsCompanion.insert(name: name, orderingName: getOrderingNameForArtist(name), spotifyId: Value(spotifyId)));
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<Artist>(createArtistFuture, name);
  }

  Future<void> createImportedArtistsInBatch(List<ImportedArtist> importedArtists) async {
    await db.createArtistsInBatch(List.from(importedArtists.map((artist) => ArtistsCompanion.insert(
        name: artist.name,
        orderingName: getOrderingNameForArtist(artist.name),
        spotifyId: Value(artist is SpotifyArtist ? artist.spotifyId : null)))));
  }

  Future<DbRequestResponse> deleteArtist(Artist artist) async {
    Future deleteArtistFuture = db.deleteArtistById(artist.id);
    return helper.wrapExceptionsAndReturnResponse(deleteArtistFuture);
  }

  Future deleteAllArtists() {
    return db.deleteAllArtists();
  }

  //
  // Tags
  //
  Stream<List<TagData>> getTagsDataList({String? searchItem = null}) {
    return db.getTagsDataList(searchItem: searchItem);
  }

  Stream<TagData?> getTagDataById(int id) {
    return db.getTagDataById(id);
  }

  Future<List<Tag>> getLatestTagsOnce(int number) {
    return db.getLatestTagsOnce(number);
  }

  Future<Set<String>> getSetOfExistingTagNames() async {
    final allTags = await db.getTagsOnce();
    return allTags.map((tag) => tag.name).toSet();
  }

  Future<DbRequestResponse<Tag>> createTag(String name, TagCategory tagCategory) {
    Future<int> createTagFuture = db.createTag(TagsCompanion.insert(name: name, category: tagCategory.id));
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<Tag>(createTagFuture, name);
  }

  Future<void> createImportedTagsInBatch(List<ImportedTag> importedTags) async {
    await db.createTagsInBatch(
        List.from(importedTags.map((tag) => TagsCompanion.insert(name: tag.name, category: tag.category.id))));
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
  Future<DbRequestResponse> assignTagToArtist(Artist artist, Tag tag) async {
    Future<int> assignTagFuture = db.assignTagToArtist(AssignedTagsCompanion.insert(artist: artist.id, tag: tag.id));
    return helper.wrapExceptionsAndReturnResponse(assignTagFuture);
  }

  Future<void> assignTagsToArtistsInBatch(Map<Artist, List<Tag>> tagsForArtistsMap) async {
    await db.assignTagsToArtistsInBatch(tagsForArtistsMap.entries
        .expand((mapEntry) =>
            mapEntry.value.map((tag) => AssignedTagsCompanion.insert(artist: mapEntry.key.id, tag: tag.id)))
        .toList());
  }

  Future<DbRequestResponse> removeTagFromArtist(Artist artist, Tag tag) {
    return helper.wrapExceptionsAndReturnResponse(db.removeTagFromArtist(artist.id, tag.id));
  }

  //
  // Tag categories
  //
  Future<DbRequestResponse<TagCategory>> createTagCategory(String name, {int? color}) {
    Future<int> createTagCategoryFuture =
        db.createTagCategory(TagCategoriesCompanion.insert(name: name, color: Value.ofNullable(color)));
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<TagCategory>(createTagCategoryFuture, name);
  }

  Future<List<TagCategory>> getTagCategoriesOnce() {
    return db.getTagCategoriesOnce();
  }

  Future<TagCategory?> getDefaultTagCategoryOnce() {
    return db.getDefaultTagCategoryOnce();
  }

  Future deleteAllTagCategories() {
    return db.deleteAllTagCategories();
  }

  //
  // Last.fm accounts
  //
  Stream<LastFmAccount?> getLastFmAccount() {
    return db.getLastFmAccount();
  }

  Future<LastFmAccount?> getLastFmAccountOnce() {
    return db.getLastFmAccountOnce();
  }

  Future<DbRequestResponse<LastFmAccount>> createOrUpdateLastFmAccount(LastFmAccount lastFmAccount) async {
    await db.deleteAllLastFmAccounts();
    Future<int> createAccountFuture = db.createOrUpdateLastFmAccount(lastFmAccount);
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<LastFmAccount>(
        createAccountFuture, lastFmAccount.accountName);
  }

  Future removeLastFmAccount() {
    Future<int> deleteAccountFuture = db.deleteAllLastFmAccounts();
    return helper.wrapExceptionsAndReturnResponse(deleteAccountFuture);
  }
}
