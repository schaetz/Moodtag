import 'package:drift/drift.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/repository_helper.dart';

import '../database/moodtag_db.dart';

class Repository {
  final MoodtagDB db;
  late final RepositoryHelper helper;

  Repository() : db = MoodtagDB() {
    helper = RepositoryHelper(db);
  }

  void close() {
    db.close();
  }

  //
  // Artists
  //
  Stream<List<ArtistData>> getArtistsDataList({Set<Tag> filterTags = const {}}) {
    return db.getArtistsDataList(filterTags);
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

  Future<bool> doesArtistHaveTag(Artist artist, Tag tag) async {
    final List<Tag> tagsWithArtist = await db.getTagsOnce(filterArtists: {artist});
    return tagsWithArtist.contains(tag);
  }

  Future<Set<String>> getSetOfExistingArtistNames() async {
    final allArtists = await db.getArtistsOnce();
    return allArtists.map((artist) => artist.name).toSet();
  }

  Future<DbRequestResponse<Artist>> createArtist(String name, {String? spotifyId}) async {
    Future<int> createArtistFuture = db.createArtist(ArtistsCompanion.insert(
        name: name, orderingName: helper.getOrderingNameForArtist(name), spotifyId: Value(spotifyId)));
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<Artist>(createArtistFuture, name);
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
  Stream<List<TagData>> getTagsDataList() {
    return db.getTagsDataList();
  }

  Stream<TagData?> getTagDataById(int id) {
    return db.getTagDataById(id);
  }

  Future<Set<String>> getSetOfExistingTagNames() async {
    final allTags = await db.getTagsOnce();
    return allTags.map((tag) => tag.name).toSet();
  }

  Future<DbRequestResponse<Tag>> createTag(String name) {
    Future<int> createTagFuture = db.createTag(TagsCompanion.insert(name: name));
    return helper.wrapExceptionsAndReturnResponseWithCreatedEntity<Tag>(createTagFuture, name);
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

  Future<DbRequestResponse> removeTagFromArtist(Artist artist, Tag tag) {
    return helper.wrapExceptionsAndReturnResponse(db.removeTagFromArtist(artist.id, tag.id));
  }

  //
  // User properties
  //
  Stream<String?> getUserProperty(String propertyKey) {
    return db.getUserProperty(propertyKey).map((userProperty) => userProperty?.propValue ?? null);
  }

  Future<String?> getUserPropertyOnce(String propertyKey) {
    return db.getUserPropertyOnce(propertyKey).then((userProperty) => userProperty?.propValue ?? null);
  }

  Future<DbRequestResponse> createOrUpdateUserProperty(String propertyKey, String? propertyValue) {
    return helper.wrapExceptionsAndReturnResponse(db.createOrUpdateUserProperty(
        UserPropertiesCompanion.insert(propKey: propertyKey, propValue: Value(propertyValue))));
  }

  Future<DbRequestResponse> deleteUserProperty(String propertyKey) {
    return helper.wrapExceptionsAndReturnResponse(
        db.createOrUpdateUserProperty(UserPropertiesCompanion.insert(propKey: propertyKey, propValue: Value(null))));
  }
}
