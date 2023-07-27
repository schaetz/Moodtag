import 'package:flutter/material.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_bloc.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_state.dart';

import '../spotify_import/spotify_import_flow_state.dart';
import 'abstract_import_flow_state.dart';

abstract class ImportFlowPageGeneratorStrategy<B extends AbstractImportBloc, S extends AbstractImportState> {
  AbstractImportFlowState createImportFlowState(S blocState);

  List<Page> onGenerateImportFlowPages(SpotifyImportFlowState importFlowState, List<Page> pages, B bloc);

  Page createMaterialPageForImportStep(int stepNumber, {required Widget screen, String? route}) {
    return MaterialPage<void>(child: screen, name: route);
  }
}
