import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/model/blocs/abstract_import/import_sub_process.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/structs/imported_entities/lastfm_artist.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';

enum LastFmImportSubProcess { createArtists, createTags, assignTags }

class LastFmImportProcessor {
  final Map<LastFmArtist, Artist> createdArtistsByEntity = Map();

  Future<Map<ImportSubProcess, DbRequestSuccessCounter>> conductImport(
      List<LastFmArtist> artistsToImport, Repository repository) async {
    final DbRequestSuccessCounter createArtistsSuccessCounter =
        await _createArtistsForImport(artistsToImport, repository);

    return {
      ImportSubProcess.createArtists: createArtistsSuccessCounter,
    };
  }

  Future<DbRequestSuccessCounter> _createArtistsForImport(List<LastFmArtist> artists, Repository repository) async {
    final DbRequestSuccessCounter creationSuccessCounter = DbRequestSuccessCounter();

    await Future.forEach(artists, (LastFmArtist lastFmArtist) async {
      DbRequestResponse<Artist> creationResponse = await repository.createArtist(lastFmArtist.name);
      if (creationResponse.changedEntity != null) {
        createdArtistsByEntity.putIfAbsent(lastFmArtist, () => creationResponse.changedEntity!);
      }
      creationSuccessCounter.registerResponse(creationResponse);
    });

    return creationSuccessCounter;
  }
}
