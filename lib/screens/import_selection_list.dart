import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/flows/import_flow_state.dart';
import 'package:moodtag/models/abstract_entity.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/tag.dart';
import 'package:moodtag/screens/selection_list.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';
import 'package:provider/provider.dart';

class ImportSelectionListScreen<N extends NamedEntity, M extends AbstractEntity> extends StatelessWidget {

  final UniqueNamedEntitySet<N> namedEntitySet;
  final String entityDenotationSingular;
  final String entityDenotationPlural;

  const ImportSelectionListScreen({Key key, this.namedEntitySet, this.entityDenotationSingular, this.entityDenotationPlural}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionList<N>(
      namedEntitySet: namedEntitySet,
      mainButtonLabel: "Import",
      onMainButtonPressed: _onImportButtonPressed
    );
  }

  void _onImportButtonPressed(BuildContext context, List<N> sortedEntities, List<bool> isBoxSelected) async {
    final requestSuccessCounter = await _createEntities(context, sortedEntities, isBoxSelected);

    if (requestSuccessCounter.totalCount == 0) {
      _showNoSelectionError(context);
    } else {
      _showSuccessMessage(context, requestSuccessCounter);

      final flowController = context.flow<ImportFlowState>();
      if (M == Artist && N == ImportedArtist) {
        _finishArtistsImportAndPrepareGenreImport(sortedEntities as List<ImportedArtist>, flowController);
      } else if (M == Tag && N == ImportedGenre) {
        _finishGenresImport(flowController);
      } else {
        throw new UnimplementedError("The functionality for importing an entity of type $M is not implemented yet.");
      }

      if (flowController.state.isArtistsImportFinished &&
          (!flowController.state.doImportGenres || flowController.state.isGenresImportFinished)) {
        flowController.complete();
      }
    }
  }

  void _finishArtistsImportAndPrepareGenreImport(List<ImportedArtist> sortedEntities, FlowController<ImportFlowState> flowController) {
    final UniqueNamedEntitySet<ImportedGenre> importedArtistsGenres = UniqueNamedEntitySet();
    sortedEntities.forEach((importedArtist) {
      List<ImportedGenre> genresList = importedArtist.genres.map((genreName) => ImportedGenre(genreName)).toList();
      genresList.forEach((genreEntity) => importedArtistsGenres.add(genreEntity));
    });
    
    flowController.update((state) => state.copyWith(
      isArtistsImportFinished: true,
      importedArtistsGenres: importedArtistsGenres,
    ));
  }

  void _finishGenresImport(FlowController<ImportFlowState> flowController) {
    flowController.update((state) => state.copyWith(isGenresImportFinished: true));
  }

  Future<DbRequestSuccessCounter> _createEntities(BuildContext context, List<N> sortedEntities, List<bool> isBoxSelected) async {
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);
    final requestSuccessCounter = new DbRequestSuccessCounter();

    for (int i=0 ; i < sortedEntities.length; i++){
      if (isBoxSelected[i]) {
        String newEntityName = sortedEntities[i].name;
        DbRequestResponse creationResponse;
        if (M == Artist) {
          creationResponse = await bloc.createArtist(newEntityName);
        } else if (M == Tag) {
          creationResponse = await bloc.createTag(newEntityName);
        } else {
          throw new UnimplementedError("The functionality for importing an entity of type $M is not implemented yet.");
        }
        requestSuccessCounter.registerResponse(creationResponse);
      }
    }

    return requestSuccessCounter;
  }

  void _showNoSelectionError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("No $entityDenotationPlural selected for import.")
        )
    );
  }

  void _showSuccessMessage(BuildContext context, DbRequestSuccessCounter requestSuccessCounter) {
    final successMessage = requestSuccessCounter.successCount == requestSuccessCounter.totalCount
        ? "Successfully added ${requestSuccessCounter.successCount} selected $entityDenotationPlural."
        : "Successfully added ${requestSuccessCounter.successCount} "
        + "out of ${requestSuccessCounter.totalCount} selected $entityDenotationPlural.";

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage))
    );
  }

}