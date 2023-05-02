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

  Stream<List<ArtistWithTagFlag>> getArtistsWithTagFlag(int tagId) {
    return db.getArtistsWithTagFlag(tagId);
  }

  Stream getArtistById(int id) {
    return db.getArtistById(id);
  }

  Future getArtistByName(String name) {
    return db.getArtistByName(name);
  }

  Future<DbRequestResponse<Artist>> createArtist(String name) async {
    Future<int> createArtistFuture =
        db.createArtist(ArtistsCompanion.insert(name: name, orderingName: _getOrderingNameForArtist(name)));
    return _wrapExceptionsAndReturnResponseWithEntity<Artist>(createArtistFuture, name);
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

  Stream getTagsWithArtistFreq() {
    return db.getTagsWithArtistFreq();
  }

  Stream getTagById(int id) {
    return db.getTagById(id);
  }

  Future getTagByName(String name) {
    return db.getTagByName(name);
  }

  Future<DbRequestResponse<Tag>> createTag(String name) {
    Future<int> createTagFuture = db.createTag(TagsCompanion.insert(name: name));
    return _wrapExceptionsAndReturnResponseWithEntity<Tag>(createTagFuture, name);
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
  Future<String?> getUserProperty(String propertyKey) {
    return db.getUserProperty(propertyKey).then((userProperty) => userProperty != null ? userProperty.propValue : null);
  }

  Future createOrUpdateUserProperty(String propertyKey, String propertyValue) {
    return db.createOrUpdateUserProperty(
        UserPropertiesCompanion.insert(propKey: propertyKey, propValue: Value(propertyValue)));
  }

  Future deleteUserProperty(String propertyKey) {
    return db.deleteUserProperty(propertyKey);
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

  Future<DbRequestResponse<E>> _wrapExceptionsAndReturnResponseWithEntity<E>(
      Future<int?> createEntityFuture, String name) async {
    Exception? exception;
    E? newEntity;

    try {
      newEntity = await createEntityFuture.then((newEntityId) async => await _getEntityById<E>(newEntityId));
    } catch (e) {
      exception = e as Exception;
    }

    if (newEntity == null) {
      if (exception == null) {
        exception = DatabaseError('The ID of the newly created entity could not be retrieved.');
      }
      return new DbRequestResponse<E>.fail(exception, parameters: [name]);
    }
    return new DbRequestResponse<E>.success(changedEntity: newEntity, parameters: [name]);
  }

  Future _getEntityById<E>(int? id) {
    if (id == null) {
      return Future.error(new InvalidArgumentException('getEntityById was called without a valid ID.'));
    }
    if (E == Artist) {
      return db.getArtistById(id).last;
    } else if (E == Tag) {
      return db.getTagById(id).last;
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
