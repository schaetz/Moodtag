import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/named_entity.dart';

import '../../utils/db_request_success_counter.dart';

// TODO Merge with CreateEntityHelper?

Future<DbRequestResponse<Artist>> createArtistOrEditExistingArtist(
    Repository repository, String newArtistName, Tag preselectedTag) async {
  final createArtistResponse = await repository.createArtist(newArtistName);

  if (preselectedTag != null) {
    if (createArtistResponse.didSucceed() && createArtistResponse.changedEntity != null) {
      await repository.assignTagToArtist(createArtistResponse.changedEntity!, preselectedTag);
    } else {
      await repository.getArtistByNameOnce(newArtistName).then((existingArtist) async {
        if (existingArtist != null) {
          await repository.assignTagToArtist(existingArtist, preselectedTag);
        }
      });
    }
  }

  return createArtistResponse;
}

Future<DbRequestResponse<Tag>> createTagOrEditExistingTag(
    Repository repository, String newTagName, Artist preselectedArtist) async {
  final createTagResponse = await repository.createTag(newTagName);

  if (preselectedArtist != null) {
    if (createTagResponse.didSucceed() && createTagResponse.changedEntity != null) {
      await repository.assignTagToArtist(preselectedArtist, createTagResponse.changedEntity!);
    } else {
      await repository
          .getTagByNameOnce(newTagName)
          .then((existingTag) async => await repository.assignTagToArtist(preselectedArtist, existingTag));
    }
  }

  return createTagResponse;
}

Future<Map<Type, DbRequestSuccessCounter>> createEntities(Repository repository, List<NamedEntity> entities) async {
  final creationSuccessCountersByType = Map<Type, DbRequestSuccessCounter>();
  final Map<ImportedArtist, Artist> createdArtistsByEntity = {};
  final Map<String, Tag> createdTagsByGenreName = {};

  for (int i = 0; i < entities.length; i++) {
    NamedEntity entity = entities[i];
    Type entityType = entity.runtimeType;

    DbRequestResponse creationResponse;
    if (entityType == ImportedArtist) {
      creationResponse = await repository.createArtist(entity.name);
      final artist = await repository.getArtistByNameOnce(entity.name);
      if (artist != null) {
        createdArtistsByEntity[entity as ImportedArtist] = artist;
      }
    } else if (entityType == ImportedGenre) {
      creationResponse = await repository.createTag(entity.name);
      final tag = await repository.getTagByNameOnce(entity.name);
      createdTagsByGenreName[entity.name] = tag;
    } else {
      throw new UnimplementedError(
          "The functionality for importing an entity of type $entityType is not implemented yet.");
    }

    creationSuccessCountersByType.putIfAbsent(entityType, () => DbRequestSuccessCounter());
    creationSuccessCountersByType[entityType]?.registerResponse(creationResponse);
  }

  _assignGenreTagsToArtists(repository, createdArtistsByEntity, createdTagsByGenreName);

  return creationSuccessCountersByType;
}

void _assignGenreTagsToArtists(Repository repository, Map<ImportedArtist, Artist> createdArtistsByEntity,
    Map<String, Tag> createdTagsByGenreName) {
  createdArtistsByEntity.forEach((importedArtistEntity, artist) {
    importedArtistEntity.genres.forEach((genreName) {
      if (createdTagsByGenreName.containsKey(genreName) && createdTagsByGenreName[genreName] != null) {
        repository.assignTagToArtist(artist, createdTagsByGenreName[genreName]!);
      }
    });
  });
}
