import 'package:flutter/material.dart';
import 'package:moodtag/shared/models/structs/imported_entities/import_entity.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/shared/models/structs/imported_entities/unique_import_entity_set.dart';
import 'package:moodtag/shared/widgets/data_display/selection_list/highlight_row_builder_strategy.dart';
import 'package:moodtag/shared/widgets/data_display/selection_list/selection_list_config.dart';
import 'package:moodtag/shared/widgets/data_display/selection_list/selection_list_screen.dart';
import 'package:moodtag/shared/widgets/import/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_app_bar.dart';

// Wrapper for the SelectionListScreen that allows handling imports of ImportEntity´s
class ImportSelectionListScreen<E extends ImportEntity> extends StatelessWidget {
  final ScaffoldBodyWrapperFactory scaffoldBodyWrapperFactory;
  final UniqueImportEntitySet<E> namedEntitySet;
  final String confirmationButtonLabel;
  final String entityDenotationSingular;
  final String entityDenotationPlural;
  final Function onSelectionConfirmed;
  final String? Function(E)? getSubtitleText;
  final IconData? subtitleIcon;

  const ImportSelectionListScreen(
      {Key? key,
      required this.scaffoldBodyWrapperFactory,
      required this.namedEntitySet,
      this.confirmationButtonLabel = "Import",
      required this.entityDenotationSingular,
      required this.entityDenotationPlural,
      required this.onSelectionConfirmed,
      this.getSubtitleText,
      this.subtitleIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionListScreen<E>(
      config: SelectionListConfig<E>(
        namedEntitySet: namedEntitySet,
        appBar: MtAppBar(context),
        scaffoldBodyWrapperFactory: scaffoldBodyWrapperFactory,
        mainButtonLabel: confirmationButtonLabel,
        onMainButtonPressed: _onConfirmButtonPressed,
        doDisableEntity: (E entity) => entity.alreadyExists,
      ),
      rowBuilderStrategy: HighlightRowBuilderStrategy<E>(
          doHighlightEntity: (ImportEntity entity) => entity.alreadyExists,
          getSubtitleText: getSubtitleText,
          getMainIcon: (E entity) => entity.alreadyExists ? (E == ImportedTag ? Icons.check : Icons.update) : null,
          getSubtitleIcon: (_) => subtitleIcon),
    );
  }

  void _onConfirmButtonPressed(
      BuildContext context, List<E> sortedEntities, Map<E, bool> isBoxSelected, int selectedBoxesCount) async {
    List<E> selectedEntities =
        isBoxSelected.entries.where((entry) => entry.value == true).map((entry) => entry.key).toList();
    onSelectionConfirmed(selectedEntities);
  }
}
