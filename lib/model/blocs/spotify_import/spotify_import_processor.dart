import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/model/blocs/abstract_import/import_sub_process.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';

class SpotifyImportProcessor {
  final Map<SpotifyArtist, Artist> createdArtistsByEntity = Map();
  final Map<String, Tag> createdTagsByGenreName = Map();

  Future<Map<ImportSubProcess, DbRequestSuccessCounter>> conductImport(
      List<SpotifyArtist> artistsToImport, List<ImportedTag> genresToImport, Repository repository) async {
    final DbRequestSuccessCounter createArtistsSuccessCounter =
        await _createArtistsForImport(artistsToImport, repository);
    final DbRequestSuccessCounter createTagsSuccessCounter =
        await _createGenreTagsForImport(genresToImport, repository);
    final DbRequestSuccessCounter assignTagsSuccessCounter = await _assignGenreTagsToArtists(repository);

    return {
      ImportSubProcess.createArtists: createArtistsSuccessCounter,
      ImportSubProcess.createTags: createTagsSuccessCounter,
      ImportSubProcess.assignTags: assignTagsSuccessCounter
    };
  }

  Future<DbRequestSuccessCounter> _createArtistsForImport(List<SpotifyArtist> artists, Repository repository) async {
    final DbRequestSuccessCounter creationSuccessCounter = DbRequestSuccessCounter();

    await Future.forEach(artists, (SpotifyArtist spotifyArtist) async {
      DbRequestResponse<Artist> creationResponse =
          await repository.createArtist(spotifyArtist.name, spotifyId: spotifyArtist.spotifyId);
      if (creationResponse.changedEntity != null) {
        createdArtistsByEntity.putIfAbsent(spotifyArtist, () => creationResponse.changedEntity!);
      }
      creationSuccessCounter.registerResponse(creationResponse);
    });

    return creationSuccessCounter;
  }

  Future<DbRequestSuccessCounter> _createGenreTagsForImport(List<ImportedTag> genres, Repository repository) async {
    final DbRequestSuccessCounter creationSuccessCounter = DbRequestSuccessCounter();

    await Future.forEach(genres, (ImportedTag ImportedTag) async {
      DbRequestResponse creationResponse = await repository.createTag(ImportedTag.name);
      if (creationResponse.changedEntity != null) {
        createdTagsByGenreName.putIfAbsent(ImportedTag.name, () => creationResponse.changedEntity!);
      }
      creationSuccessCounter.registerResponse(creationResponse);
    });

    return creationSuccessCounter;
  }

  Future<DbRequestSuccessCounter> _assignGenreTagsToArtists(Repository repository) async {
    final DbRequestSuccessCounter successCounter = DbRequestSuccessCounter();

    await Future.forEach(createdArtistsByEntity.entries, (MapEntry<SpotifyArtist, Artist> createdArtistPair) async {
      final SpotifyArtist SpotifyArtistEntity = createdArtistPair.key;
      final Artist artist = createdArtistPair.value;
      await Future.forEach(SpotifyArtistEntity.tags, (genreName) async {
        if (createdTagsByGenreName.containsKey(genreName) && createdTagsByGenreName[genreName] != null) {
          DbRequestResponse assignTagsResponse =
              await repository.assignTagToArtist(artist, createdTagsByGenreName[genreName]!);
          successCounter.registerResponse(assignTagsResponse);
        }
      });
    });

    return successCounter;
  }
}
