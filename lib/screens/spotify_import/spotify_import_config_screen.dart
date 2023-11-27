import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/import_config_form.dart';
import 'package:moodtag/components/mt_main_scaffold.dart';
import 'package:moodtag/components/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/import_events.dart';

import '../../model/blocs/spotify_import/spotify_import_option.dart';

class SpotifyImportConfigScreen extends StatelessWidget {
  final ScaffoldBodyWrapperFactory scaffoldBodyWrapperFactory;

  const SpotifyImportConfigScreen({Key? key, required this.scaffoldBodyWrapperFactory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyImportBloc>();
    return MtMainScaffold(
        scaffoldKey: GlobalKey<ScaffoldState>(),
        pageWidget: scaffoldBodyWrapperFactory.create(
            bodyWidget: Center(
                child: ImportConfigForm(
          headlineCaption: 'Select what should be imported:',
          sendButtonCaption: 'Start Spotify Import',
          configItemsWithCaption: _getConfigItemsWithCaption(),
          initialConfig: _getConfigItemsWithInitialValues(bloc.state),
          onChangeSelection: (Map<String, bool> newSelection) => _onChangeSelection(newSelection, bloc),
        ))),
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
    return Map.fromEntries(SpotifyImportOption.values.map((option) => MapEntry(option.name, option.caption)));
  }

  Map<String, bool> _getConfigItemsWithInitialValues(SpotifyImportState state) {
    final Map<String, bool> configItemsWithInitialValues = {};
    SpotifyImportOption.values.forEach((option) {
      configItemsWithInitialValues[option.name] = state.configuration[option] ?? false;
    });
    return configItemsWithInitialValues;
  }

  void _onChangeSelection(Map<String, bool> newSelection, SpotifyImportBloc bloc) {
    bloc.add(ChangeImportConfig(newSelection));
  }

  void _confirmImportConfiguration(SpotifyImportBloc bloc) async {
    bloc.add(ConfirmImportConfig());
  }
}
