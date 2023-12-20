import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/models/structs/imported_entities/lastfm_artist.dart';

class LastFmImportProcessor {
  final Map<LastFmArtist, Artist> createdArtistsByEntity = Map();

  Future<void> conductImport(List<LastFmArtist> artistsToImport, Repository repository) async {
    await repository.createImportedArtistsInBatch(artistsToImport);
  }
}
