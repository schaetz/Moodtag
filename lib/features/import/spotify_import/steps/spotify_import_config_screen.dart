import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_option.dart';
import 'package:moodtag/features/import/spotify_import/bloc/spotify_import_bloc.dart';
import 'package:moodtag/features/import/spotify_import/bloc/spotify_import_state.dart';
import 'package:moodtag/features/import/spotify_import/config/spotify_import_config.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/shared/bloc/events/import_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/dialogs/alert_dialog_factory.dart';
import 'package:moodtag/shared/utils/optional.dart';
import 'package:moodtag/shared/widgets/data_display/display_wrapper/loaded_data_display_wrapper.dart';
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
    final dialogFactory = context.read<AlertDialogFactory>();
    return MtMainScaffold(
        scaffoldKey: GlobalKey<ScaffoldState>(),
        pageWidget: scaffoldBodyWrapperFactory.create(
            bodyWidget: Center(
                child: BlocBuilder<SpotifyImportBloc, SpotifyImportState>(
                    builder: (context, state) => !state.isInitialized
                        ? Container()
                        : MultiLoadedDataDisplayWrapper<List<LibraryEntityWithId>, TagCategoriesList>.additionalChecks(
                            loadedDataList: [bloc.state.allTagCategories, bloc.state.allTags],
                            buildOnSuccess: (tagCategories) =>
                                ImportConfigForm<SpotifyImportConfig, SpotifyImportOption, SpotifyImportBloc, SpotifyImportState>(
                                    headlineCaption: 'Select what should be imported:',
                                    sendButtonCaption: 'Start Spotify Import',
                                    optionsWithCaption: _getOptionsWithCaption(),
                                    showTagCategoriesDropdown: true,
                                    tagCategories: tagCategories,
                                    tags: bloc.state.allTags.data!,
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
                                        .show(onTruthyResult: (input) => bloc.add(CreateTags(input!)))))))),
        floatingActionButton: BlocBuilder<SpotifyImportBloc, SpotifyImportState>(
            builder: (context, state) => !state.isInitialized || state.importConfig == null
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

  void _onChangeImportConfig(Optional<Map<AbstractImportOption, bool>> checkboxSelections,
      Optional<TagCategory> newTagCategory, Optional<BaseTag?> newBaseTag, SpotifyImportBloc bloc) {
    bloc.add(ChangeImportConfig(checkboxSelections, newTagCategory, newBaseTag));
  }

  void _confirmImportConfiguration(SpotifyImportBloc bloc) async {
    bloc.add(ConfirmImportConfig());
  }
}
