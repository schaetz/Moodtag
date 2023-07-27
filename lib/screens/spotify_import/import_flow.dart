import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/app_bar_context_data.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/spotify_events.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/screens/import_selection_list/import_selection_list_screen.dart';
import 'package:moodtag/screens/spotify_import/spotify_import_config_screen.dart';
import 'package:moodtag/screens/spotify_import/spotify_import_confirmation_screen.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/utils/i10n.dart';
import 'package:provider/provider.dart';

import 'import_flow_screen_wrapper_factory.dart';
import 'import_flow_state.dart';

class ImportFlow extends StatelessWidget {
  static const importSteps = 4;

  final String _importName;

  const ImportFlow(this._importName);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyImportBloc>();
    return BlocConsumer<SpotifyImportBloc, SpotifyImportState>(listener: (context, state) {
      if (state.step == SpotifyImportFlowStep.finished) {
        _returnToLibraryScreens(context);
      }
    }, builder: (context, state) {
      return Provider(
          create: (_) => AppBarContextData(onBackButtonPressed: () => _onBackButtonPressed(context, bloc)),
          child: FlowBuilder<ImportFlowState>(
            state: ImportFlowState(step: state.step, doShowGenreImportScreen: state.doImportGenres),
            onGeneratePages: (ImportFlowState importFlowState, List<Page> pages) =>
                _onGenerateImportFlowPages(importFlowState, pages, bloc),
          ));
    });
  }

  double _calculateImportProgress(SpotifyImportFlowStep step) => (step.index + 1) / importSteps;

  String _getCaptionText(SpotifyImportFlowStep step) {
    int stepNumber = step.index + 1;
    return "$_importName ($stepNumber/$importSteps)";
  }

  ImportFlowScreenWrapperFactory _getImportFlowScreenWrapperFactory(SpotifyImportFlowStep step) =>
      ImportFlowScreenWrapperFactory(_calculateImportProgress(step), _getCaptionText(step));

  List<Page> _onGenerateImportFlowPages(ImportFlowState importFlowState, List<Page> pages, SpotifyImportBloc bloc) {
    return [
      _createMaterialPageForImportStep(1,
          screen: SpotifyImportConfigScreen(
              scaffoldBodyWrapperFactory: _getImportFlowScreenWrapperFactory(bloc.state.step)),
          route: Routes.spotifyImport),
      if (importFlowState.step.index >= SpotifyImportFlowStep.artistsSelection.index)
        _createMaterialPageForImportStep(2, screen: _getArtistsSelectionScreen(bloc)),
      if (importFlowState.step.index >= SpotifyImportFlowStep.genreTagsSelection.index &&
          importFlowState.doShowGenreImportScreen)
        _createMaterialPageForImportStep(3, screen: _getGenreSelectionScreen(bloc)),
      if (importFlowState.step.index >= SpotifyImportFlowStep.confirmation.index)
        _createMaterialPageForImportStep(4,
            screen: SpotifyImportConfirmationScreen(
                scaffoldBodyWrapperFactory: _getImportFlowScreenWrapperFactory(bloc.state.step)),
            route: Routes.spotifyImport)
    ];
  }

  Page _createMaterialPageForImportStep(int stepNumber, {required Widget screen, String? route}) {
    return MaterialPage<void>(child: screen, name: route);
  }

  void _onBackButtonPressed(BuildContext context, SpotifyImportBloc bloc) {
    if (bloc.state.step.index <= SpotifyImportFlowStep.config.index) {
      _returnToLibraryScreens(context);
    } else {
      bloc.add(ReturnToPreviousImportScreen(this));
    }
  }

  Widget _getArtistsSelectionScreen(SpotifyImportBloc bloc) {
    return ImportSelectionListScreen<ImportedArtist>(
      scaffoldBodyWrapperFactory: _getImportFlowScreenWrapperFactory(bloc.state.step),
      namedEntitySet: bloc.state.availableSpotifyArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: I10n.ARTIST_DENOTATION_SINGULAR,
      entityDenotationPlural: I10n.ARTIST_DENOTATION_PLURAL,
      onSelectionConfirmed: (List<ImportedArtist> selectedArtists) =>
          bloc.add(ConfirmArtistsForSpotifyImport(selectedArtists)),
    );
  }

  Widget _getGenreSelectionScreen(SpotifyImportBloc bloc) {
    return ImportSelectionListScreen<ImportedGenre>(
      scaffoldBodyWrapperFactory: _getImportFlowScreenWrapperFactory(bloc.state.step),
      namedEntitySet: bloc.state.availableGenresForSelectedArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: "genre tag",
      entityDenotationPlural: "genre tags",
      onSelectionConfirmed: (List<ImportedGenre> selectedGenres) =>
          bloc.add(ConfirmGenreTagsForSpotifyImport(selectedGenres)),
    );
  }

  void _returnToLibraryScreens(BuildContext context) async {
    Navigator.of(context).popUntil(ModalRouteExt.withNames(Routes.artistsList, Routes.tagsList));
  }
}
