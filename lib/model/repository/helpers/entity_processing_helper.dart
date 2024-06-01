import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/repository.dart';

Future<Map<String, BaseArtist>> getMapFromArtistNameToBaseArtistObject(Repository repository) async {
  List<BaseArtist> allArtists = await repository.getBaseArtistsOnce();

  final artistNameToObject = Map<String, BaseArtist>();
  allArtists.forEach((baseArtist) {
    artistNameToObject[baseArtist.name] = baseArtist;
  });
  return artistNameToObject;
}
