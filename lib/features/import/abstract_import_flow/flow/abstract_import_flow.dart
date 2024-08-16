import 'package:flutter/material.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/features/import/abstract_import_flow/bloc/abstract_import_bloc.dart';
import 'package:moodtag/shared/bloc/events/import_events.dart';

import '../screen_wrapper/import_flow_screen_wrapper_factory.dart';

abstract class AbstractImportFlow extends StatelessWidget {
  final String _importName;
  final int _importSteps;

  AbstractImportFlow(this._importName, this._importSteps);

  Page createMaterialPageForImportStep({required Widget screen, String? route}) {
    return MaterialPage<void>(child: screen, name: route);
  }

  void onBackButtonPressed(BuildContext context, AbstractImportBloc bloc, int configIndex) {
    if (bloc.state.step.index <= configIndex) {
      returnToAppSettingsScreen(context);
    } else {
      bloc.add(ReturnToPreviousImportScreen(this));
    }
  }

  void returnToAppSettingsScreen(BuildContext context) async {
    Navigator.of(context).popUntil(ModalRouteExt.withName(Routes.appSettings));
  }

  ImportFlowScreenWrapperFactory getImportFlowScreenWrapperFactory(int stepIndex) =>
      ImportFlowScreenWrapperFactory(_calculateImportProgress(stepIndex), _getCaptionText(stepIndex));

  double _calculateImportProgress(int stepIndex) => (stepIndex + 1) / _importSteps;

  String _getCaptionText(int stepIndex) {
    int stepNumber = stepIndex + 1;
    return "$_importName ($stepNumber/$_importSteps)";
  }
}
