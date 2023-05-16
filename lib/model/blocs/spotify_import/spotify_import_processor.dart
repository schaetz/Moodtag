import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';

enum ImportSubProcess { createArtists, createTags, assignTags }

class SpotifyImportProcessor {
  final Map<ImportedArtist, Artist> createdArtistsByEntity = Map();
  final Map<String, Tag> createdTagsByGenreName = Map();

  Future<Map<ImportSubProcess, DbRequestSuccessCounter>> conductImport(
      List<ImportedArtist> artistsToImport, List<ImportedGenre> genresToImport, Repository repository) async {
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

  Future<DbRequestSuccessCounter> _createArtistsForImport(List<ImportedArtist> artists, Repository repository) async {
    final DbRequestSuccessCounter creationSuccessCounter = DbRequestSuccessCounter();

    await Future.forEach(artists, (ImportedArtist importedArtist) async {
      DbRequestResponse<Artist> creationResponse = await repository.createArtist(importedArtist.name);
      if (creationResponse.changedEntity != null) {
        createdArtistsByEntity.putIfAbsent(importedArtist, () => creationResponse.changedEntity!);
      }
      creationSuccessCounter.registerResponse(creationResponse);
    });

    return creationSuccessCounter;
  }

  Future<DbRequestSuccessCounter> _createGenreTagsForImport(List<ImportedGenre> genres, Repository repository) async {
    final DbRequestSuccessCounter creationSuccessCounter = DbRequestSuccessCounter();

    await Future.forEach(genres, (ImportedGenre importedGenre) async {
      DbRequestResponse creationResponse = await repository.createTag(importedGenre.name);
      if (creationResponse.changedEntity != null) {
        createdTagsByGenreName.putIfAbsent(importedGenre.name, () => creationResponse.changedEntity!);
      }
      creationSuccessCounter.registerResponse(creationResponse);
    });

    return creationSuccessCounter;
  }

  Future<DbRequestSuccessCounter> _assignGenreTagsToArtists(Repository repository) async {
    final DbRequestSuccessCounter successCounter = DbRequestSuccessCounter();

    await Future.forEach(createdArtistsByEntity.entries, (MapEntry<ImportedArtist, Artist> createdArtistPair) async {
      final ImportedArtist importedArtistEntity = createdArtistPair.key;
      final Artist artist = createdArtistPair.value;
      await Future.forEach(importedArtistEntity.genres, (genreName) async {
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
