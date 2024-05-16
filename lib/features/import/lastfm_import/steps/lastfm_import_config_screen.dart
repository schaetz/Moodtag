import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_bloc.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_state.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_config.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_option.dart';
import 'package:moodtag/shared/bloc/events/import_events.dart';
import 'package:moodtag/shared/widgets/data_display/loaded_data_display_wrapper.dart';
import 'package:moodtag/shared/widgets/import/import_config_form.dart';
import 'package:moodtag/shared/widgets/import/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_app_bar.dart';

class LastFmImportConfigScreen extends StatelessWidget {
  final ScaffoldBodyWrapperFactory scaffoldBodyWrapperFactory;

  const LastFmImportConfigScreen({Key? key, required this.scaffoldBodyWrapperFactory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LastFmImportBloc>();
    return Scaffold(
        appBar: MtAppBar(context),
        body: scaffoldBodyWrapperFactory.create(
            bodyWidget: Center(
                child: BlocBuilder<LastFmImportBloc, LastFmImportState>(
                    builder: (context, state) => !state.isInitialized
                        ? Container()
                        : LoadedDataDisplayWrapper(
                            loadedData: state.allTagCategories,
                            additionalCheckData: state.allTags,
                            buildOnSuccess: (tagCategories) => ImportConfigForm<LastFmImportConfig, LastFmImportOption>(
                                  headlineCaption: 'Select what should be imported:',
                                  sendButtonCaption: 'Start LastFm Import',
                                  optionsWithCaption: _getOptionsWithCaption(),
                                  tagCategories: tagCategories,
                                  tags: state.allTags.data!,
                                  initialConfig: bloc.state.importConfig!,
                                  onChangeSelection: (Map<LastFmImportOption, bool> newSelection) =>
                                      _onChangeSelection(newSelection, bloc),
                                ))))),
        floatingActionButton: BlocBuilder<LastFmImportBloc, LastFmImportState>(
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

  Map<LastFmImportOption, String> _getOptionsWithCaption() {
    return Map.fromEntries(LastFmImportOption.values.map((option) => MapEntry(option, option.caption)));
  }

  void _onChangeSelection(Map<LastFmImportOption, bool> newSelection, LastFmImportBloc bloc) {
    bloc.add(ChangeImportConfig(newSelection));
  }

  void _confirmImportConfiguration(LastFmImportBloc bloc) async {
    bloc.add(ConfirmImportConfig());
  }
}
