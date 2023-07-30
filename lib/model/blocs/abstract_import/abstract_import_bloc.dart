import 'package:bloc/bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_state.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_processor.dart';
import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/structs/imported_entities/imported_artist.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';

class AbstractImportBloc<S extends AbstractImportState> extends Bloc<ImportEvent, S> {
  final Repository _repository;
  Repository get repository => _repository;
  final CreateEntityBlocHelper createEntityBlocHelper = CreateEntityBlocHelper();

  AbstractImportBloc(super.initialState, this._repository);

  Future annotateImportedArtistsWithAlreadyExistsProp(UniqueNamedEntitySet<ImportedArtist> entities) async {
    final existingArtistNames = await _repository.getSetOfExistingArtistNames();
    entities.values.forEach((entity) {
      if (existingArtistNames.contains(entity.name)) {
        entity.alreadyExists = true;
      }
    });
  }

  Future annotateImportedTagsWithAlreadyExistsProp(UniqueNamedEntitySet<ImportedTag> entities) async {
    final existingTagNames = await _repository.getSetOfExistingTagNames();
    entities.values.forEach((entity) {
      if (existingTagNames.contains(entity.name)) {
        entity.alreadyExists = true;
      }
    });
  }

  Future<UniqueNamedEntitySet<ImportedTag>> getAvailableTagsForSelectedArtists(
      List<SpotifyArtist> selectedArtists) async {
    final UniqueNamedEntitySet<ImportedTag> availableTagsForSelectedArtists = UniqueNamedEntitySet();
    selectedArtists.forEach((artist) {
      List<ImportedTag> tagsList = artist.tags.map((tagName) => ImportedTag(tagName)).toList();
      tagsList.forEach((genreEntity) => availableTagsForSelectedArtists.add(genreEntity));
    });

    if (!availableTagsForSelectedArtists.isEmpty) {
      await annotateImportedTagsWithAlreadyExistsProp(availableTagsForSelectedArtists);
    }

    return availableTagsForSelectedArtists;
  }

  String getResultMessage(Map<ImportSubProcess, DbRequestSuccessCounter> creationSuccessCountersByType) {
    String message;

    if (creationSuccessCountersByType[ImportSubProcess.createArtists] == null) {
      message = "No entities were added.";
    } else {
      final successfulArtists = creationSuccessCountersByType[ImportSubProcess.createArtists]?.successCount ?? 0;
      final successfulTags = creationSuccessCountersByType[ImportSubProcess.createTags]?.successCount ?? 0;
      if (successfulArtists > 0) {
        if (successfulTags > 0) {
          message = "Successfully added ${successfulArtists} artists and ${successfulTags} tags.";
        } else {
          message = "Successfully added ${successfulArtists} artists.";
        }
      } else if (successfulTags > 0) {
        message = "Successfully added ${successfulTags} tags.";
      } else {
        message = "No entities were added.";
      }
    }

    return message;
  }
}
