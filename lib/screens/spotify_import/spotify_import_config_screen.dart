import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/import_config_form.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/spotify_events.dart';

import 'import_flow_state.dart';

enum SpotifyImportOption { topArtists, followedArtists, artistGenres }

class SpotifyImportConfigScreen extends StatelessWidget {
  const SpotifyImportConfigScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyImportBloc>();
    return Scaffold(
        appBar: MtAppBar(context, onBackButtonPressed: () => context.flow<ImportFlowState>().complete()),
        body: Center(
            child: ImportConfigForm(
          headlineCaption: 'Select what should be imported:',
          sendButtonCaption: 'Start Spotify Import',
          configItemsWithCaption: _getConfigItemsWithCaption(),
          initialConfig: _getConfigItemsWithInitialValues(bloc.state),
          onChangeSelection: (Map<String, bool> newSelection) => _onChangeSelection(newSelection, bloc),
        )),
        floatingActionButton: BlocBuilder<SpotifyImportBloc, SpotifyImportState>(
            builder: (context, state) => FloatingActionButton.extended(
                  onPressed: state.isConfigurationValid ? () => _confirmImportConfiguration(bloc) : null,
                  label: Text('OK'),
                  icon: const Icon(Icons.library_add),
                  backgroundColor: state.isConfigurationValid
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey, // TODO Define color in theme
                )));
  }

  Map<String, String> _getConfigItemsWithCaption() {
    final Map<String, String> configItemsWithCaption = {
      SpotifyImportOption.topArtists.name: 'Top artists',
      SpotifyImportOption.followedArtists.name: 'Followed artists',
      SpotifyImportOption.artistGenres.name: 'Artist genres'
    };
    return configItemsWithCaption;
  }

  Map<String, bool> _getConfigItemsWithInitialValues(SpotifyImportState state) {
    final Map<String, bool> configItemsWithInitialValues = {};
    SpotifyImportOption.values.forEach((option) {
      configItemsWithInitialValues[option.name] = state.configuration[option] ?? false;
    });
    return configItemsWithInitialValues;
  }

  void _onChangeSelection(Map<String, bool> newSelection, SpotifyImportBloc bloc) {
    bloc.add(ChangeConfigForSpotifyImport(newSelection));
  }

  void _confirmImportConfiguration(SpotifyImportBloc bloc) async {
    bloc.add(ConfirmConfigForSpotifyImport());
  }
}
