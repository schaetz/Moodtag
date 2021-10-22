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

}