import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/app_bar_context_data.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_flow_step.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/spotify_import_events.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/screens/import_flow/abstract_import_flow.dart';
import 'package:moodtag/screens/import_selection_list/import_selection_list_screen.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/utils/i10n.dart';
import 'package:provider/provider.dart';

import '../spotify_import/spotify_import_flow_state.dart';
import 'spotify_import_config_screen.dart';
import 'spotify_import_confirmation_screen.dart';

class SpotifyImportFlow extends AbstractImportFlow {
  SpotifyImportFlow() : super('Spotify Import', 4);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyImportBloc>();
    return BlocConsumer<SpotifyImportBloc, SpotifyImportState>(listener: (context, state) {
      if (state.isFinished) {
        returnToLibraryScreens(context);
      }
    }, builder: (context, state) {
      return Provider(
          create: (_) => AppBarContextData(
              onBackButtonPressed: () => onBackButtonPressed(context, bloc, SpotifyImportFlowStep.config.index)),
          child: FlowBuilder<SpotifyImportFlowState>(
            state: SpotifyImportFlowState(step: state.step),
            onGeneratePages: (SpotifyImportFlowState importFlowState, List<Page> pages) =>
                onGenerateImportFlowPages(importFlowState, pages, bloc),
          ));
    });
  }

  List<Page> onGenerateImportFlowPages(
      SpotifyImportFlowState importFlowState, List<Page> pages, SpotifyImportBloc bloc) {
    final List<SpotifyImportFlowStep> flowStepsTillCurrentStep =
        SpotifyImportFlowStep.values.where((step) => importFlowState.step.index >= step.index).toList();

    return flowStepsTillCurrentStep
        .map((step) => createMaterialPageForImportStep(step.index,
            screen: _getScreenForFlowStep(bloc, step), route: Routes.spotifyImport))
        .toList();
  }

  Widget _getScreenForFlowStep(SpotifyImportBloc bloc, SpotifyImportFlowStep step) {
    switch (step) {
      case SpotifyImportFlowStep.config:
        return SpotifyImportConfigScreen(
            scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index));
      case SpotifyImportFlowStep.artistsSelection:
        return _getArtistsSelectionScreen(bloc);
      case SpotifyImportFlowStep.genreTagsSelection:
        return _getGenreSelectionScreen(bloc);
      case SpotifyImportFlowStep.confirmation:
        return SpotifyImportConfirmationScreen(
            scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index));
    }
  }

  Widget _getArtistsSelectionScreen(SpotifyImportBloc bloc) {
    return ImportSelectionListScreen<SpotifyArtist>(
      scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index),
      namedEntitySet: bloc.state.availableSpotifyArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: I10n.ARTIST_DENOTATION_SINGULAR,
      entityDenotationPlural: I10n.ARTIST_DENOTATION_PLURAL,
      onSelectionConfirmed: (List<SpotifyArtist> selectedArtists) =>
          bloc.add(ConfirmSpotifyArtistsForImport(selectedArtists)),
    );
  }

  Widget _getGenreSelectionScreen(SpotifyImportBloc bloc) {
    return ImportSelectionListScreen<ImportedTag>(
      scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index),
      namedEntitySet: bloc.state.availableGenresForSelectedArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: "genre tag",
      entityDenotationPlural: "genre tags",
      onSelectionConfirmed: (List<ImportedTag> selectedGenres) => bloc.add(ConfirmGenreTagsForImport(selectedGenres)),
    );
  }
}
