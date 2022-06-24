import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

import 'moodtag_db.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/exceptions/invalid_argument_exception.dart';

class MoodtagBloc {

  final MoodtagDB db;

  final BehaviorSubject<List<Artist>> _allArtists = BehaviorSubject();
  Stream<List<Artist>> get artists => _allArtists;

  final BehaviorSubject<List<Tag>> _allTags = BehaviorSubject();
  Stream<List<Tag>> get tags => _allTags;

  // Solely for testing purposes
  final BehaviorSubject<List<AssignedTag>> _allArtistTagPairs = BehaviorSubject();
  Stream<List<AssignedTag>> get artistTagPairs => _allArtistTagPairs;

  MoodtagBloc() : db = MoodtagDB() {
    db.allArtists.listen(_allArtists.add);
    db.allTags.listen(_allTags.add);
    db.allArtistTagPairs.listen(_allArtistTagPairs.add);
  }

  void close() {
    db.close();
    _allArtists.close();
    _allTags.close();
    _allArtistTagPairs.close();
  }


  //
  // Artists
  //
  Future getArtistById(int id) {
    return db.getArtistById(id);
  }

  Future getArtistByName(String name) {
    return db.getArtistByName(name);
  }

  Future<DbRequestResponse<Artist>> createArtist(String name) async {
    Future<int> createArtistFuture = db.createArtist(ArtistsCompanion.insert(name: name));
    return _getCreatedEntityFromId<Artist>(createArtistFuture, name);
  }

  Future deleteArtist(Artist artist) {
    return db.deleteArtistById(artist.id);
  }

  Stream<List<Artist>> artistsWithTag(Tag tag) {
    return db.artistsWithTag(tag.id).watch();
  }

  Future deleteAllArtists() {
    return db.deleteAllArtists();
  }


  //
  // Tags
  //
  Future getTagById(int id) {
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

  Stream<List<Tag>> tagsForArtist(Artist artist) {
    return db.tagsForArtist(artist.id).watch();
  }

  Future deleteAllTags() {
    return db.deleteAllTags();
  }


  //
  // Assigned tags
  //
  Future assignTagToArtist(Artist artist, Tag tag) {
    return db.assignTagToArtist(
        AssignedTagsCompanion.insert(artist: artist.id, tag: tag.id)
    );
  }

  Future removeTagFromArtist(Artist artist, Tag tag) {
    return db.removeTagFromArtist(artist.id, tag.id);
  }

  Future<bool> artistHasTag(Artist artist, Tag tag) {
    return db.tagsForArtist(artist.id).get().then(
            (tagsList) => tagsList.contains(tag)
    );
  }


  //
  // User properties
  //
  Future<String> getUserProperty(String propertyKey) {
    return db.getUserProperty(propertyKey)
             .then((userProperty) => userProperty.propValue);
  }

  Future createOrUpdateUserProperty(String propertyKey, String propertyValue) {
    return db.createOrUpdateUserProperty(UserPropertiesCompanion.insert(propKey: propertyKey, propValue: Value(propertyValue)));
  }


  //
  // Helper methods
  //
  Future<DbRequestResponse<E>> _getCreatedEntityFromId<E>(Future<int> createEntityFuture, String name) async {
    Exception exception;
    E newEntity = await createEntityFuture.catchError((e) {
      exception = e;
      return null;
    }).then(
      (newEntityId) async => await _getEntityById<E>(newEntityId)
    );

    if (newEntity == null) {
      return new DbRequestResponse<E>.fail(exception, [name]);
    }
    return new DbRequestResponse<E>.success(newEntity, [name]);
  }

  Future _getEntityById<E>(int id) {
    if (E == Artist) {
      return db.getArtistById(id);
    } else if (E == Tag) {
      return db.getTagById(id);
    } else {
      return Future.error(
          new InvalidArgumentException('getEntityById was called with an invalid entity type: ' + E.toString())
      );
    }
  }

}