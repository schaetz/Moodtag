import 'package:flutter/material.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/navigation/routes.dart';

import 'import_flow_screen_wrapper_factory.dart';

abstract class AbstractImportFlow extends StatelessWidget {
  final String _importName;
  final int _importSteps;

  AbstractImportFlow(this._importName, this._importSteps);

  Page createMaterialPageForImportStep(int stepNumber, {required Widget screen, String? route}) {
    return MaterialPage<void>(child: screen, name: route);
  }

  void onBackButtonPressed(BuildContext context, AbstractImportBloc bloc) {
    if (bloc.state.step.index <= SpotifyImportFlowStep.config.index) {
      returnToLibraryScreens(context);
    } else {
      bloc.add(ReturnToPreviousImportScreen(this));
    }
  }

  void returnToLibraryScreens(BuildContext context) async {
    Navigator.of(context).popUntil(ModalRouteExt.withNames(Routes.artistsList, Routes.tagsList));
  }

  ImportFlowScreenWrapperFactory getImportFlowScreenWrapperFactory(SpotifyImportFlowStep step) =>
      ImportFlowScreenWrapperFactory(_calculateImportProgress(step), _getCaptionText(step));

  double _calculateImportProgress(SpotifyImportFlowStep step) => (step.index + 1) / _importSteps;

  String _getCaptionText(SpotifyImportFlowStep step) {
    int stepNumber = step.index + 1;
    return "$_importName ($stepNumber/$_importSteps)";
  }
}
