import 'package:rxdart/rxdart.dart';

import 'moodtag_db.dart';
import 'package:moodtag/exceptions/db_request_response.dart';

class MoodtagBloc {

  final MoodtagDB db;

  final BehaviorSubject<List<Artist>> _allArtists = BehaviorSubject();
  Stream<List<Artist>> get artists => _allArtists;

  MoodtagBloc() : db = MoodtagDB() {
    db.allArtists.listen(_allArtists.add);
  }

  void close() {
    db.close();
    _allArtists.close();
  }

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
  
  Future assignTagToArtist(Artist artist, Tag tag) {
    return db.assignTagToArtist(
        AssignedTagsCompanion.insert(artist: artist.id, tag: tag.id)
    );
  }
  
  Future deleteArtist(Artist artist) {
    return db.deleteArtistById(artist.id);
  }

  Stream<List<Artist>> artistsWithTag(Tag tag) {
    return db.artistsWithTag(tag.id).watch();
  }


  Future getTagById(int id) {
    return db.getTagById(id);
  }

  Future createTag(String name) {
    return db.createTag(TagsCompanion.insert(name: name));
  }

  Future deleteTag(Tag tag) {
    return db.deleteTagById(tag.id);
  }

}