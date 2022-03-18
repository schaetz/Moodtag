import 'package:flutter/material.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/models/abstract_entity.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/tag.dart';
import 'package:moodtag/screens/selection_list.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';
import 'package:provider/provider.dart';

class ImportSelectionListScreen<N extends NamedEntity, M extends AbstractEntity> extends StatelessWidget {

  final String entityDenotationSingular;
  final String entityDenotationPlural;

  const ImportSelectionListScreen({Key key, this.entityDenotationSingular, this.entityDenotationPlural}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionList<N>(
      mainButtonLabel: "Import",
      onMainButtonPressed: _onImportButtonPressed
    );
  }

  void _onImportButtonPressed(BuildContext context, List<String> entityNames, List<bool> isBoxSelected) async {
    final requestSuccessCounter = await _createEntities(context, entityNames, isBoxSelected);

    if (requestSuccessCounter.totalCount == 0) {
      _showNoSelectionError(context);
    } else {
      _showSuccessMessage(context, requestSuccessCounter);

      // TODO Route from artists import screen to genres import screen
      Navigator.of(context).popUntil(ModalRouteExt.withNames(Routes.artistsList, Routes.tagsList));
    }
  }

  Future<DbRequestSuccessCounter> _createEntities(BuildContext context, List<String> entityNames, List<bool> isBoxSelected) async {
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);
    final requestSuccessCounter = new DbRequestSuccessCounter();

    for (int i=0 ; i < entityNames.length; i++){
      if (isBoxSelected[i]) {
        String newEntityName = entityNames[i];
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