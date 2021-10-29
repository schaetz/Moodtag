import 'package:rxdart/rxdart.dart';

import 'moodtag_db.dart';

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

  Future createArtist(String name) {
    return db.createArtist(ArtistsCompanion.insert(name: name));
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