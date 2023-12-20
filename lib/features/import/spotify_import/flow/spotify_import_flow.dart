import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/features/import/abstract_import_flow/flow/abstract_import_flow.dart';
import 'package:moodtag/features/import/import_selection_list/import_selection_list_screen.dart';
import 'package:moodtag/features/import/spotify_import/bloc/spotify_import_bloc.dart';
import 'package:moodtag/features/import/spotify_import/bloc/spotify_import_state.dart';
import 'package:moodtag/features/import/spotify_import/flow/spotify_import_flow_step.dart';
import 'package:moodtag/shared/bloc/events/spotify_import_events.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/shared/models/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/shared/utils/i10n.dart';
import 'package:moodtag/shared/widgets/main_layout/app_bar_context_data.dart';
import 'package:provider/provider.dart';

import '../steps/spotify_import_config_screen.dart';
import '../steps/spotify_import_confirmation_screen.dart';
import 'spotify_import_flow_state.dart';

class SpotifyImportFlow extends AbstractImportFlow {
  SpotifyImportFlow() : super('Spotify Import', SpotifyImportFlowStep.values.length);

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
