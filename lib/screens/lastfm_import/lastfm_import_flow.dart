import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/app_bar_context_data.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_bloc.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_flow_step.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_state.dart';
import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/model/events/lastfm_import_events.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/screens/import_flow/abstract_import_flow.dart';
import 'package:moodtag/screens/import_selection_list/import_selection_list_screen.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/lastfm_artist.dart';
import 'package:moodtag/utils/i10n.dart';
import 'package:provider/provider.dart';

import 'lastfm_import_config_screen.dart';
import 'lastfm_import_confirmation_screen.dart';
import 'lastfm_import_flow_state.dart';

class LastFmImportFlow extends AbstractImportFlow {
  LastFmImportFlow() : super('Last.fm Import', 4);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LastFmImportBloc>();
    return BlocConsumer<LastFmImportBloc, LastFmImportState>(listener: (context, state) {
      if (state.isFinished) {
        returnToLibraryScreens(context);
      }
    }, builder: (context, state) {
      return Provider(
          create: (_) => AppBarContextData(
              onBackButtonPressed: () => onBackButtonPressed(context, bloc, LastFmImportFlowStep.config.index)),
          child: FlowBuilder<LastFmImportFlowState>(
            state: LastFmImportFlowState(step: state.step),
            onGeneratePages: (LastFmImportFlowState importFlowState, List<Page> pages) =>
                onGenerateImportFlowPages(importFlowState, pages, bloc),
          ));
    });
  }

  List<Page> onGenerateImportFlowPages(LastFmImportFlowState importFlowState, List<Page> pages, LastFmImportBloc bloc) {
    final List<LastFmImportFlowStep> flowStepsTillCurrentStep =
        LastFmImportFlowStep.values.where((step) => importFlowState.step.index >= step.index).toList();

    return flowStepsTillCurrentStep
        .map((step) => createMaterialPageForImportStep(step.index,
            screen: _getScreenForFlowStep(bloc, step), route: Routes.lastFmImport))
        .toList();
  }

  Widget _getScreenForFlowStep(LastFmImportBloc bloc, LastFmImportFlowStep step) {
    switch (step) {
      case LastFmImportFlowStep.config:
        return LastFmImportConfigScreen(
            scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index));
      case LastFmImportFlowStep.artistsSelection:
        return _getArtistsSelectionScreen(bloc);
      case LastFmImportFlowStep.tagsSelection:
        return _getTagsSelectionScreen(bloc);
      case LastFmImportFlowStep.confirmation:
        return LastFmImportConfirmationScreen(
            scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index));
    }
  }

  Widget _getArtistsSelectionScreen(LastFmImportBloc bloc) {
    return ImportSelectionListScreen<LastFmArtist>(
      scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index),
      namedEntitySet: bloc.state.availableLastFmArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: I10n.ARTIST_DENOTATION_SINGULAR,
      entityDenotationPlural: I10n.ARTIST_DENOTATION_PLURAL,
      onSelectionConfirmed: (List<LastFmArtist> selectedArtists) =>
          bloc.add(ConfirmLastFmArtistsForImport(selectedArtists)),
    );
  }

  Widget _getTagsSelectionScreen(LastFmImportBloc bloc) {
    return ImportSelectionListScreen<ImportedTag>(
      scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index),
      namedEntitySet: bloc.state.availableTagsForSelectedArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: "tag",
      entityDenotationPlural: "tags",
      onSelectionConfirmed: (List<ImportedTag> selectedGenres) => bloc.add(ConfirmTagsForImport(selectedGenres)),
    );
  }
}
