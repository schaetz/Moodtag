import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/spotify_import/bloc/spotify_import_bloc.dart';
import 'package:moodtag/features/import/spotify_import/bloc/spotify_import_state.dart';
import 'package:moodtag/features/import/spotify_import/config/spotify_import_config.dart';
import 'package:moodtag/shared/bloc/events/import_events.dart';
import 'package:moodtag/shared/widgets/data_display/loaded_data_display_wrapper.dart';
import 'package:moodtag/shared/widgets/import/import_config_form.dart';
import 'package:moodtag/shared/widgets/import/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_main_scaffold.dart';

import '../config/spotify_import_option.dart';

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
                child: LoadedDataDisplayWrapper(
                    loadedData: bloc.state.allTagCategories,
                    additionalCheckData: bloc.state.allTags,
                    buildOnSuccess: (tagCategories) => ImportConfigForm<SpotifyImportConfig, SpotifyImportOption>(
                          headlineCaption: 'Select what should be imported:',
                          sendButtonCaption: 'Start Spotify Import',
                          optionsWithCaption: _getOptionsWithCaption(),
                          tagCategories: tagCategories,
                          tags: bloc.state.allTags.data!,
                          initialConfig: bloc.state.importConfig!,
                          onChangeSelection: (Map<SpotifyImportOption, bool> newSelection) =>
                              _onChangeSelection(newSelection, bloc),
                        )))),
        floatingActionButton: BlocBuilder<SpotifyImportBloc, SpotifyImportState>(
            builder: (context, state) => state.importConfig == null
                ? Container()
                : FloatingActionButton.extended(
                    onPressed: state.importConfig!.isValid ? () => _confirmImportConfiguration(bloc) : null,
                    label: Text('OK'),
                    icon: const Icon(Icons.library_add),
                    backgroundColor: state.importConfig!.isValid
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey, // TODO Define color in theme
                  )));
  }

  Map<SpotifyImportOption, String> _getOptionsWithCaption() {
    return Map.fromEntries(SpotifyImportOption.values.map((option) => MapEntry(option, option.caption)));
  }

  void _onChangeSelection(Map<SpotifyImportOption, bool> newSelection, SpotifyImportBloc bloc) {
    bloc.add(ChangeImportConfig(newSelection));
  }

  void _confirmImportConfiguration(SpotifyImportBloc bloc) async {
    bloc.add(ConfirmImportConfig());
  }
}
