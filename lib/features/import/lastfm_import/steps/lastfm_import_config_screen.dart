import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_option.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_bloc.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_state.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_config.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_option.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/shared/bloc/events/import_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/dialogs/alert_dialog_factory.dart';
import 'package:moodtag/shared/utils/optional.dart';
import 'package:moodtag/shared/widgets/import/import_config_form.dart';
import 'package:moodtag/shared/widgets/import/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_app_bar.dart';

class LastFmImportConfigScreen extends StatelessWidget {
  final ScaffoldBodyWrapperFactory scaffoldBodyWrapperFactory;

  const LastFmImportConfigScreen({Key? key, required this.scaffoldBodyWrapperFactory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LastFmImportBloc>();
    final dialogFactory = context.read<AlertDialogFactory>();
    return Scaffold(
        appBar: MtAppBar(context),
        body: scaffoldBodyWrapperFactory.create(
            bodyWidget: Center(
                child: BlocBuilder<LastFmImportBloc, LastFmImportState>(
                    builder: (context, state) => !state.isInitialized
                        ? Container()
                        : ImportConfigForm<LastFmImportConfig, LastFmImportOption, LastFmImportBloc, LastFmImportState>(
                            headlineCaption: 'Select what should be imported:',
                            sendButtonCaption: 'Start LastFm Import',
                            optionsWithCaption: _getOptionsWithCaption(),
                            showTagCategoriesDropdown: false,
                            tagCategories: null,
                            tags: state.allTags.data!,
                            initialConfig: bloc.state.importConfig!,
                            onChangeImportConfig: (Optional<Map<AbstractImportOption, bool>> checkboxSelections,
                                    Optional<TagCategory> newTagCategory, Optional<BaseTag?> newBaseTag) =>
                                _onChangeImportConfig(checkboxSelections, newTagCategory, newBaseTag, bloc),
                            onPressAddTagButton: () => dialogFactory
                                .getSingleTextInputDialog(context,
                                    title: 'Create new tag(s)',
                                    subtitle: 'Separate multiple tags by line breaks',
                                    multiline: true,
                                    maxLines: 10)
                                .show(onTruthyResult: (input) => bloc.add(CreateTags(input!))))))),
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

  void _onChangeImportConfig(Optional<Map<AbstractImportOption, bool>> checkboxSelections,
      Optional<TagCategory> newTagCategory, Optional<BaseTag?> newBaseTag, LastFmImportBloc bloc) {
    bloc.add(ChangeImportConfig(checkboxSelections, newTagCategory, newBaseTag));
  }

  void _confirmImportConfiguration(LastFmImportBloc bloc) async {
    bloc.add(ConfirmImportConfig());
  }
}
