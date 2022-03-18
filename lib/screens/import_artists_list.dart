import 'package:flutter/material.dart';
import 'package:moodtag/screens/selection_list.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';
import 'package:provider/provider.dart';

class ImportArtistsListScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SelectionList(
      mainButtonLabel: "Import",
      onMainButtonPressed: _onImportButtonPressed
    );
  }

  void _onImportButtonPressed(BuildContext context, List<String> artistsNames, List<bool> isBoxSelected) async {
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);
    final requestSuccessCounter = new DbRequestSuccessCounter();

    for (int i=0 ; i < artistsNames.length; i++){
      if (isBoxSelected[i]) {
        String newArtistName = artistsNames[i];
        final createArtistResponse = await bloc.createArtist(newArtistName);
        requestSuccessCounter.registerResponse(createArtistResponse);
      }
    }

    if (requestSuccessCounter.totalCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("No artists selected for import.")
          )
      );
    } else {
      final successMessage = requestSuccessCounter.successCount == requestSuccessCounter.totalCount
        ? "Successfully added ${requestSuccessCounter.successCount} selected artists."
        : "Successfully added ${requestSuccessCounter.successCount} "
          + "out of ${requestSuccessCounter.totalCount} selected artists.";

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage))
      );

      Navigator.of(context).popUntil(ModalRouteExt.withNames(Routes.artistsList, Routes.tagsList));
    }
  }

}