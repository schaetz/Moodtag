import 'package:diacritic/diacritic.dart';
import 'package:drift/drift.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/exceptions/invalid_argument_exception.dart';

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
  Stream getArtists() {
    return db.getArtists();
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
    return _getCreatedEntityFromId<Artist>(createArtistFuture, name);
  }

  Future deleteArtist(Artist artist) {
    return db.deleteArtistById(artist.id);
  }

  Stream getArtistsWithTag(int tagId) {
    return db.tagsForArtist(tagId).watch();
  }

  Future deleteAllArtists() {
    return db.deleteAllArtists();
  }

  //
  // Tags
  //
  Stream getTags() {
    return db.getTags();
  }

  Stream getTagById(int id) {
    return db.getTagById(id);
  }

  Future getTagByName(String name) {
    return db.getTagByName(name);
  }

  Future<DbRequestResponse<Tag>> createTag(String name) {
    Future<int> createTagFuture = db.createTag(TagsCompanion.insert(name: name));
    return _getCreatedEntityFromId<Tag>(createTagFuture, name);
  }

  Future deleteTag(Tag tag) {
    return db.deleteTagById(tag.id);
  }

  Stream getTagsForArtist(int artistId) {
    return db.tagsForArtist(artistId).watch();
  }

  Future deleteAllTags() {
    return db.deleteAllTags();
  }

  //
  // Assigned tags
  //
  Future assignTagToArtist(Artist artist, Tag tag) {
    return db.assignTagToArtist(AssignedTagsCompanion.insert(artist: artist.id, tag: tag.id));
  }

  Future removeTagFromArtist(Artist artist, Tag tag) {
    return db.removeTagFromArtist(artist.id, tag.id);
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
  Future<DbRequestResponse<E>> _getCreatedEntityFromId<E>(Future<int> createEntityFuture, String name) async {
    Exception exception = Exception();
    E newEntity = await createEntityFuture.catchError((e) {
      exception = e;
      return null;
    }).then((newEntityId) async => await _getEntityById<E>(newEntityId));

    if (newEntity == null) {
      return new DbRequestResponse<E>.fail(exception, [name]);
    }
    return new DbRequestResponse<E>.success(newEntity, [name]);
  }

  Future _getEntityById<E>(int id) {
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
