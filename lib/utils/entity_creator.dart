import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:provider/provider.dart';

import 'db_request_success_counter.dart';

Future<Map<Type, DbRequestSuccessCounter>>createEntities(BuildContext context, List<NamedEntity> entities) async {
  final bloc = Provider.of<MoodtagBloc>(context, listen: false);
  final creationSuccessCountersByType = Map<Type, DbRequestSuccessCounter>();

  for (int i=0 ; i < entities.length; i++){
    NamedEntity entity = entities[i];
    Type entityType = entity.runtimeType;

    DbRequestResponse creationResponse;
    if (entityType == ImportedArtist) {
      creationResponse = await bloc.createArtist(entity.name);
    } else if (entityType == ImportedGenre) {
      creationResponse = await bloc.createTag(entity.name);
    } else {
      throw new UnimplementedError("The functionality for importing an entity of type $entityType is not implemented yet.");
    }

    creationSuccessCountersByType.putIfAbsent(entityType, () => DbRequestSuccessCounter());
    creationSuccessCountersByType[entityType].registerResponse(creationResponse);
  }

  return creationSuccessCountersByType;
}
