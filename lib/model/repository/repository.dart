import 'package:diacritic/diacritic.dart';
import 'package:drift/drift.dart';
import 'package:moodtag/exceptions/database_error.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/exceptions/invalid_argument_exception.dart';
import 'package:moodtag/model/database/join_data_classes.dart';

import '../database/moodtag_db.dart';

class Repository {
  final MoodtagDB db;

  Repository() : db = MoodtagDB();

  void close() {
    db.close();
  }

  //
  // Artists
  //
  Stream<List<Artist>> getArtists() {
    return db.getArtists();
  }

  Future<List<Artist>> getArtistsOnce() {
    return db.getArtistsOnce();
  }

  Future<Set<String>> getSetOfExistingArtistNames() async {
    final allArtists = await db.getArtistsOnce();
    return allArtists.map((artist) => artist.name).toSet();
  }

  Stream<List<ArtistWithTagFlag>> getArtistsWithTagFlag(int tagId) {
    return db.getArtistsWithTagFlag(tagId);
  }

  Stream<Artist?> getArtistById(int id) {
    return db.getArtistById(id);
  }

  Future<Artist?> getArtistByNameOnce(String name) {
    return db.getArtistByNameOnce(name);
  }

  Future<DbRequestResponse<Artist>> createArtist(String name) async {
    Future<int> createArtistFuture =
        db.createArtist(ArtistsCompanion.insert(name: name, orderingName: _getOrderingNameForArtist(name)));
    return _wrapExceptionsAndReturnResponseWithCreatedEntity<Artist>(createArtistFuture, name);
  }

  Future<DbRequestResponse> deleteArtist(Artist artist) async {
    Future deleteArtistFuture = db.deleteArtistById(artist.id);
    return _wrapExceptionsAndReturnResponse(deleteArtistFuture);
  }

  Stream<List<Artist>> getArtistsWithTag(int tagId) {
    return db.artistsWithTag(tagId).watch();
  }

  Future deleteAllArtists() {
    return db.deleteAllArtists();
  }

  //
  // Tags
  //
  Stream<List<Tag>> getTags() {
    return db.getTags();
  }

  Future<List<Tag>> getTagsOnce() {
    return db.getTagsOnce();
  }

  Future<Set<String>> getSetOfExistingTagNames() async {
    final allTags = await db.getTagsOnce();
    return allTags.map((tag) => tag.name).toSet();
  }

  Stream<List<TagWithArtistFreq>> getTagsWithArtistFreq() {
    return db.getTagsWithArtistFreq();
  }

  Stream<Tag?> getTagById(int id) {
    return db.getTagById(id);
  }

  Future getTagByNameOnce(String name) {
    return db.getTagByNameOnce(name);
  }

  Future<DbRequestResponse<Tag>> createTag(String name) {
    Future<int> createTagFuture = db.createTag(TagsCompanion.insert(name: name));
    return _wrapExceptionsAndReturnResponseWithCreatedEntity<Tag>(createTagFuture, name);
  }

  Future<DbRequestResponse> deleteTag(Tag tag) {
    Future deleteArtistFuture = db.deleteTagById(tag.id);
    return _wrapExceptionsAndReturnResponse(deleteArtistFuture);
  }

  Stream<List<Tag>> getTagsForArtist(int artistId) {
    return db.tagsForArtist(artistId).watch();
  }

  Future deleteAllTags() {
    return db.deleteAllTags();
  }

  //
  // Assigned tags
  //
  Future<DbRequestResponse> assignTagToArtist(Artist artist, Tag tag) async {
    Future<int> assignTagFuture = db.assignTagToArtist(AssignedTagsCompanion.insert(artist: artist.id, tag: tag.id));
    return _wrapExceptionsAndReturnResponse(assignTagFuture);
  }

  Future<DbRequestResponse> removeTagFromArtist(Artist artist, Tag tag) {
    return _wrapExceptionsAndReturnResponse(db.removeTagFromArtist(artist.id, tag.id));
  }

  Future<bool> artistHasTag(Artist artist, Tag tag) {
    return db.tagsForArtist(artist.id).get().then((tagsList) => tagsList.contains(tag));
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
    return _wrapExceptionsAndReturnResponse(db.createOrUpdateUserProperty(
        UserPropertiesCompanion.insert(propKey: propertyKey, propValue: Value(propertyValue))));
  }

  Future<DbRequestResponse> deleteUserProperty(String propertyKey) {
    return _wrapExceptionsAndReturnResponse(
        db.createOrUpdateUserProperty(UserPropertiesCompanion.insert(propKey: propertyKey, propValue: Value(null))));
  }

  //
  // Helper methods
  //
  Future<DbRequestResponse> _wrapExceptionsAndReturnResponse(Future changedEntityFuture) async {
    Exception? exception = null;
    await changedEntityFuture.onError<Exception>((e, stackTrace) {
      exception = e;
    });

    if (exception != null) {
      return new DbRequestResponse.fail(exception);
    }
    return new DbRequestResponse.success();
  }

  Future<DbRequestResponse<E>> _wrapExceptionsAndReturnResponseWithCreatedEntity<E>(
      Future<int?> createEntityFuture, String name) async {
    try {
      E? newEntity = await createEntityFuture.then((newEntityId) async => await _getEntityById<E>(newEntityId));

      if (newEntity == null) {
        final exception = DatabaseError('The ID of the newly created entity could not be retrieved.');
        return new DbRequestResponse<E>.fail(exception, parameters: [name]);
      }
      return new DbRequestResponse<E>.success(changedEntity: newEntity, parameters: [name]);
    } on Exception catch (e) {
      return new DbRequestResponse<E>.fail(e, parameters: [name]);
    }
  }

  Future<E?> _getEntityById<E>(int? id) {
    if (id == null) {
      return Future.error(new InvalidArgumentException('getEntityById was called without a valid ID.'));
    }

    if (E == Artist) {
      return db.getArtistByIdOnce(id) as Future<E?>;
    } else if (E == Tag) {
      return db.getTagByIdOnce(id) as Future<E?>;
    } else {
      return Future.error(
          new InvalidArgumentException('getEntityById was called with an invalid entity type: ' + E.toString()));
    }
  }

  String _getOrderingNameForArtist(String artistName) {
    final lowerCased = artistName.toLowerCase();
    final diacriticsReplaced = removeDiacritics(lowerCased);
    final leadingTheRemoved = diacriticsReplaced.replaceFirst(RegExp('^the\\s'), '');
    print("$artistName => $leadingTheRemoved");
    return leadingTheRemoved;
  }
}
