import 'package:flutter/material.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/selection_list/highlight_selection_list_screen.dart';
import 'package:moodtag/components/selection_list/selection_list_config.dart';
import 'package:moodtag/structs/import_entity.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

// Wrapper for the HighlightSelectionListScreen that allows handling imports of ImportEntity´s
class ImportSelectionListScreen<E extends ImportEntity> extends StatelessWidget {
  final UniqueNamedEntitySet<E> namedEntitySet;
  final String confirmationButtonLabel;
  final String entityDenotationSingular;
  final String entityDenotationPlural;
  final Function onSelectionConfirmed;

  const ImportSelectionListScreen(
      {Key? key,
      required this.namedEntitySet,
      this.confirmationButtonLabel = "Import",
      required this.entityDenotationSingular,
      required this.entityDenotationPlural,
      required this.onSelectionConfirmed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HighlightSelectionListScreen(
      config: SelectionListConfig<E>(
        namedEntitySet: namedEntitySet,
        appBar: MtAppBar(context),
        mainButtonLabel: confirmationButtonLabel,
        onMainButtonPressed: _onConfirmButtonPressed,
      ),
      doHighlightEntity: (E entity) => entity.alreadyExists,
      doDisableEntity: (E entity) => entity.alreadyExists && E == _typeOf<ImportedGenre>(),
    );
  }

  void _onConfirmButtonPressed(
      BuildContext context, List<E> sortedEntities, List<bool> isBoxSelected, int selectedBoxesCount) async {
    List<E> selectedEntities = _filterOutUnselectedEntities(sortedEntities, isBoxSelected);
    onSelectionConfirmed(selectedEntities);
  }

  List<E> _filterOutUnselectedEntities(List<E> sortedEntities, List<bool> isBoxSelected) {
    List<E> selectedEntities = [];
    for (int i = 0; i < sortedEntities.length; i++) {
      if (isBoxSelected[i]) {
        selectedEntities.add(sortedEntities[i]);
      }
    }
    return selectedEntities;
  }

  Type _typeOf<T>() => T;
}
