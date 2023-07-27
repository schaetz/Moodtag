import 'package:flutter/widgets.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/screens/import_flow/abstract_import_flow_state.dart';
import 'package:moodtag/screens/import_flow/import_flow_page_generator_strategy.dart';
import 'package:moodtag/screens/import_flow/import_flow_screen_wrapper_factory.dart';
import 'package:moodtag/screens/import_selection_list/import_selection_list_screen.dart';
import 'package:moodtag/screens/spotify_import/spotify_import_flow_state.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/utils/i10n.dart';

import 'spotify_import_config_screen.dart';
import 'spotify_import_confirmation_screen.dart';

class SpotifyImportFlowPageGeneratorStrategy
    extends ImportFlowPageGeneratorStrategy<SpotifyImportBloc, SpotifyImportState> {
  final int _importSteps;
  final String _importName;

  SpotifyImportFlowPageGeneratorStrategy(this._importName, this._importSteps);

  AbstractImportFlowState createImportFlowState(SpotifyImportState blocState) {
    return SpotifyImportFlowState(step: blocState.step, doShowGenreImportScreen: blocState.doImportGenres);
  }

  @override
  List<Page> onGenerateImportFlowPages(
      SpotifyImportFlowState importFlowState, List<Page> pages, SpotifyImportBloc bloc) {
    return [
      createMaterialPageForImportStep(1,
          screen: SpotifyImportConfigScreen(
              scaffoldBodyWrapperFactory: _getImportFlowScreenWrapperFactory(bloc.state.step)),
          route: Routes.spotifyImport),
      if (importFlowState.step.index >= SpotifyImportFlowStep.artistsSelection.index)
        createMaterialPageForImportStep(2, screen: _getArtistsSelectionScreen(bloc)),
      if (importFlowState.step.index >= SpotifyImportFlowStep.genreTagsSelection.index &&
          importFlowState.doShowGenreImportScreen)
        createMaterialPageForImportStep(3, screen: _getGenreSelectionScreen(bloc)),
      if (importFlowState.step.index >= SpotifyImportFlowStep.confirmation.index)
        createMaterialPageForImportStep(4,
            screen: SpotifyImportConfirmationScreen(
                scaffoldBodyWrapperFactory: _getImportFlowScreenWrapperFactory(bloc.state.step)),
            route: Routes.spotifyImport)
    ];
  }

  Widget _getArtistsSelectionScreen(SpotifyImportBloc bloc) {
    return ImportSelectionListScreen<ImportedArtist>(
      scaffoldBodyWrapperFactory: _getImportFlowScreenWrapperFactory(bloc.state.step),
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
      scaffoldBodyWrapperFactory: _getImportFlowScreenWrapperFactory(bloc.state.step),
      namedEntitySet: bloc.state.availableGenresForSelectedArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: "genre tag",
      entityDenotationPlural: "genre tags",
      onSelectionConfirmed: (List<ImportedGenre> selectedGenres) => bloc.add(ConfirmGenreTagsForImport(selectedGenres)),
    );
  }

  double _calculateImportProgress(SpotifyImportFlowStep step) => (step.index + 1) / _importSteps;

  String _getCaptionText(SpotifyImportFlowStep step) {
    int stepNumber = step.index + 1;
    return "$_importName ($stepNumber/$_importSteps)";
  }

  ImportFlowScreenWrapperFactory _getImportFlowScreenWrapperFactory(SpotifyImportFlowStep step) =>
      ImportFlowScreenWrapperFactory(_calculateImportProgress(step), _getCaptionText(step));
}
