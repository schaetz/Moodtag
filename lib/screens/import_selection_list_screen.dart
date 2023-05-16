import 'package:flutter/material.dart';
import 'package:moodtag/screens/spotify_import/spotify_selection_list_screen.dart';
import 'package:moodtag/structs/import_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

// Wrapper for the SelectionListScreen that allows handling imports of ImportEntity´s
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
    // TODO This screen should be independent of Spotify and work for other imports, too
    return SpotifySelectionListScreen<E>(
        namedEntitySet: namedEntitySet,
        mainButtonLabel: confirmationButtonLabel,
        onMainButtonPressed: _onConfirmButtonPressed);
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
}
