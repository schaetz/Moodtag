import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';

Future<Map<String, Artist>> getMapFromArtistNameToObject(Repository repository) async {
  List<Artist> allArtists = await repository.getArtistsOnce();

  final artistNameToObject = Map<String, Artist>();
  allArtists.forEach((artist) {
    artistNameToObject[artist.name] = artist;
  });
  return artistNameToObject;
}
