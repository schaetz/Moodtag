import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/import_config_form.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_bloc.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_option.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_state.dart';
import 'package:moodtag/model/events/import_events.dart';

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
                child: ImportConfigForm(
          headlineCaption: 'Select what should be imported:',
          sendButtonCaption: 'Start LastFm Import',
          configItemsWithCaption: _getConfigItemsWithCaption(),
          initialConfig: _getConfigItemsWithInitialValues(bloc.state),
          onChangeSelection: (Map<String, bool> newSelection) => _onChangeSelection(newSelection, bloc),
        ))),
        floatingActionButton: BlocBuilder<LastFmImportBloc, LastFmImportState>(
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
    return Map.fromEntries(LastFmImportOption.values.map((option) => MapEntry(option.name, option.caption)));
  }

  Map<String, bool> _getConfigItemsWithInitialValues(LastFmImportState state) {
    final Map<String, bool> configItemsWithInitialValues = {};
    LastFmImportOption.values.forEach((option) {
      configItemsWithInitialValues[option.name] = state.configuration[option] ?? false;
    });
    return configItemsWithInitialValues;
  }

  void _onChangeSelection(Map<String, bool> newSelection, LastFmImportBloc bloc) {
    bloc.add(ChangeImportConfig(newSelection));
  }

  void _confirmImportConfiguration(LastFmImportBloc bloc) async {
    bloc.add(ConfirmImportConfig());
  }
}
