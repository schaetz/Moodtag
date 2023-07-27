import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/app_bar_context_data.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/screens/import_flow/import_flow_page_generator_strategy.dart';
import 'package:provider/provider.dart';

import '../spotify_import/spotify_import_flow_state.dart';

class ImportFlow<GenericImportBloc extends AbstractImportBloc> extends StatelessWidget {
  final ImportFlowPageGeneratorStrategy pageGeneratorStrategy;

  const ImportFlow(this.pageGeneratorStrategy);

  @override
  Widget build(BuildContext context) {
    if (GenericImportBloc != SpotifyImportBloc) {
      print('ERROR: Unexpected import bloc!');
      return Container(); // TODO Handle different imports than Spotify
    }
    final bloc = context.read<SpotifyImportBloc>();
    return BlocConsumer<SpotifyImportBloc, SpotifyImportState>(listener: (context, state) {
      if (state.step == SpotifyImportFlowStep.finished) {
        _returnToLibraryScreens(context);
      }
    }, builder: (context, state) {
      return Provider(
          create: (_) =>
              AppBarContextData(onBackButtonPressed: () => _onBackButtonPressed(context, bloc as GenericImportBloc)),
          child: FlowBuilder<SpotifyImportFlowState>(
            state: pageGeneratorStrategy.createImportFlowState(bloc.state) as SpotifyImportFlowState,
            onGeneratePages: (SpotifyImportFlowState importFlowState, List<Page> pages) =>
                pageGeneratorStrategy.onGenerateImportFlowPages(importFlowState, pages, bloc),
          ));
    });
  }

  void _onBackButtonPressed(BuildContext context, GenericImportBloc bloc) {
    if (bloc.state.step.index <= SpotifyImportFlowStep.config.index) {
      _returnToLibraryScreens(context);
    } else {
      bloc.add(ReturnToPreviousImportScreen(this));
    }
  }

  void _returnToLibraryScreens(BuildContext context) async {
    Navigator.of(context).popUntil(ModalRouteExt.withNames(Routes.artistsList, Routes.tagsList));
  }
}
