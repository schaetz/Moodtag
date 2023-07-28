import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/app_bar_context_data.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/screens/import_flow/abstract_import_flow.dart';
import 'package:moodtag/screens/import_selection_list/import_selection_list_screen.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
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
      if (state.step == SpotifyImportFlowStep.finished) {
        returnToLibraryScreens(context);
      }
    }, builder: (context, state) {
      return Provider(
          create: (_) => AppBarContextData(onBackButtonPressed: () => onBackButtonPressed(context, bloc)),
          child: FlowBuilder<SpotifyImportFlowState>(
            state: SpotifyImportFlowState(step: state.step, doShowGenreImportScreen: state.doImportGenres),
            onGeneratePages: (SpotifyImportFlowState importFlowState, List<Page> pages) =>
                onGenerateImportFlowPages(importFlowState, pages, bloc),
          ));
    });
  }

  List<Page> onGenerateImportFlowPages(
      SpotifyImportFlowState importFlowState, List<Page> pages, SpotifyImportBloc bloc) {
    return [
      createMaterialPageForImportStep(1,
          screen:
              SpotifyImportConfigScreen(scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step)),
          route: Routes.spotifyImport),
      if (importFlowState.step.index >= SpotifyImportFlowStep.artistsSelection.index)
        createMaterialPageForImportStep(2, screen: _getArtistsSelectionScreen(bloc)),
      if (importFlowState.step.index >= SpotifyImportFlowStep.genreTagsSelection.index &&
          importFlowState.doShowGenreImportScreen)
        createMaterialPageForImportStep(3, screen: _getGenreSelectionScreen(bloc)),
      if (importFlowState.step.index >= SpotifyImportFlowStep.confirmation.index)
        createMaterialPageForImportStep(4,
            screen: SpotifyImportConfirmationScreen(
                scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step)),
            route: Routes.spotifyImport)
    ];
  }

  Page createMaterialPageForImportStep(int stepNumber, {required Widget screen, String? route}) {
    return MaterialPage<void>(child: screen, name: route);
  }

  Widget _getArtistsSelectionScreen(SpotifyImportBloc bloc) {
    return ImportSelectionListScreen<ImportedArtist>(
      scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step),
      namedEntitySet: bloc.state.availableSpotifyArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: I10n.ARTIST_DENOTATION_SINGULAR,
      entityDenotationPlural: I10n.ARTIST_DENOTATION_PLURAL,
      onSelectionConfirmed: (List<ImportedArtist> selectedArtists) =>
          bloc.add(ConfirmArtistsForImport(selectedArtists)),
    );
  }

  Widget _getGenreSelectionScreen(SpotifyImportBloc bloc) {
    return ImportSelectionListScreen<ImportedGenre>(
      scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step),
      namedEntitySet: bloc.state.availableGenresForSelectedArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: "genre tag",
      entityDenotationPlural: "genre tags",
      onSelectionConfirmed: (List<ImportedGenre> selectedGenres) => bloc.add(ConfirmGenreTagsForImport(selectedGenres)),
    );
  }
}
