import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:provider/provider.dart';

import '../../utils/db_request_success_counter.dart';

Future<DbRequestResponse<Artist>> createArtistOrEditExistingArtist(
    Repository repository, String newArtistName, Tag preselectedTag) async {
  final createArtistResponse = await repository.createArtist(newArtistName);

  if (preselectedTag != null) {
    if (createArtistResponse.didSucceed() && createArtistResponse.changedEntity != null) {
      await repository.assignTagToArtist(createArtistResponse.changedEntity!, preselectedTag);
    } else {
      await repository
          .getArtistByName(newArtistName)
          .then((existingArtist) async => await repository.assignTagToArtist(existingArtist, preselectedTag));
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
          .getTagByName(newTagName)
          .then((existingTag) async => await repository.assignTagToArtist(preselectedArtist, existingTag));
    }
  }

  return createTagResponse;
}

Future<Map<Type, DbRequestSuccessCounter>> createEntities(BuildContext context, List<NamedEntity> entities) async {
  // TODO Replace direct repository call by bloc
  final bloc = Provider.of<Repository>(context, listen: false);
  final creationSuccessCountersByType = Map<Type, DbRequestSuccessCounter>();
  final Map<ImportedArtist, Artist> createdArtistsByEntity = {};
  final Map<String, Tag> createdTagsByGenreName = {};

  for (int i = 0; i < entities.length; i++) {
    NamedEntity entity = entities[i];
    Type entityType = entity.runtimeType;

    DbRequestResponse creationResponse;
    if (entityType == ImportedArtist) {
      creationResponse = await bloc.createArtist(entity.name);
      final artist = await bloc.getArtistByName(entity.name);
      createdArtistsByEntity[entity as ImportedArtist] = artist;
    } else if (entityType == ImportedGenre) {
      creationResponse = await bloc.createTag(entity.name);
      final tag = await bloc.getTagByName(entity.name);
      createdTagsByGenreName[entity.name] = tag;
    } else {
      throw new UnimplementedError(
          "The functionality for importing an entity of type $entityType is not implemented yet.");
    }

    creationSuccessCountersByType.putIfAbsent(entityType, () => DbRequestSuccessCounter());
    creationSuccessCountersByType[entityType]?.registerResponse(creationResponse);
  }

  _assignGenreTagsToArtists(bloc, createdArtistsByEntity, createdTagsByGenreName);

  return creationSuccessCountersByType;
}

void _assignGenreTagsToArtists(
    Repository bloc, Map<ImportedArtist, Artist> createdArtistsByEntity, Map<String, Tag> createdTagsByGenreName) {
  createdArtistsByEntity.forEach((importedArtistEntity, artist) {
    importedArtistEntity.genres.forEach((genreName) {
      if (createdTagsByGenreName.containsKey(genreName) && createdTagsByGenreName[genreName] != null) {
        bloc.assignTagToArtist(artist, createdTagsByGenreName[genreName]!);
      }
    });
  });
}
