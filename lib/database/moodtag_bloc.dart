import 'package:rxdart/rxdart.dart';

import 'moodtag_db.dart';
import 'package:moodtag/exceptions/db_request_response.dart';

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

  Future<DbRequestResponse<Artist>> createArtist(String name) async {
    Future<int> newArtistIdFuture = db.createArtist(ArtistsCompanion.insert(name: name));
    Exception exception;
    Artist newArtist = await newArtistIdFuture
        .catchError((e) {
          exception = e;
          return null;
        })
        .then((newArtistId) async => await getArtistById(newArtistId));

    if (newArtist == null) {
      return new DbRequestResponse<Artist>.fail(exception);
    }
    return new DbRequestResponse<Artist>.success(newArtist);
  }

  Future deleteArtist(Artist artist) {
    return db.deleteArtistById(artist.id);
  }

  Stream<List<Artist>> artistsWithTag(Tag tag) {
    return db.artistsWithTag(tag.id).watch();
  }


  //
  // Tags
  //
  Future getTagById(int id) {
    return db.getTagById(id);
  }

  Future createTag(String name) {
    return db.createTag(TagsCompanion.insert(name: name));
  }

  Future deleteTag(Tag tag) {
    return db.deleteTagById(tag.id);
  }

  Stream<List<Tag>> tagsForArtist(Artist artist) {
    return db.tagsForArtist(artist.id).watch();
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

}