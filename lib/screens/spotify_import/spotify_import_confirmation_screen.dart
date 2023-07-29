import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/spotify_import_events.dart';
import 'package:moodtag/screens/import_flow/abstract_import_confirmation_screen.dart';

class SpotifyImportConfirmationScreen extends AbstractImportConfirmationScreen {
  SpotifyImportConfirmationScreen({Key? key, required ScaffoldBodyWrapperFactory scaffoldBodyWrapperFactory})
      : super(key: key, scaffoldBodyWrapperFactory: scaffoldBodyWrapperFactory);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyImportBloc>();
    return Scaffold(
        key: scaffoldKey,
        appBar: MtAppBar(context),
        body: scaffoldBodyWrapperFactory.create(
            bodyWidget: Center(child: BlocBuilder<SpotifyImportBloc, SpotifyImportState>(builder: (context, state) {
          return getImportedEntitiesOverviewList(_getEntityFrequencies(state));
        }))),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (bloc.state.selectedArtists != null && bloc.state.selectedGenres != null) {
              bloc.add(CompleteSpotifyImport(bloc.state.selectedArtists!, bloc.state.selectedGenres!));
            } else {
              bloc.errorStreamController.add(UnknownError('Something went wrong.'));
            }
          },
          label: Text('Import'),
          icon: const Icon(Icons.library_add),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ));
  }

  Map<String, int> _getEntityFrequencies(SpotifyImportState state) {
    final Map<String, int> entityFreq = {};
    if (state.selectedArtists != null && state.selectedArtists!.isNotEmpty) {
      entityFreq.putIfAbsent('Artists', () => state.selectedArtists!.length);
    }
    if (state.selectedGenres != null && state.selectedGenres!.isNotEmpty) {
      entityFreq.putIfAbsent('Genres', () => state.selectedGenres!.length);
    }
    return entityFreq;
  }
}
