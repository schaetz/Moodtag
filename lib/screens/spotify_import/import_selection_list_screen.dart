import 'package:flutter/material.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/screens/selection_list_screen.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

// TODO Can be abstracted to use for other imports, not only Spotify
class ImportSelectionListScreen<N extends NamedEntity> extends StatelessWidget {
  final SpotifyImportBloc bloc;
  final UniqueNamedEntitySet<N> namedEntitySet;
  final String confirmationButtonLabel;
  final String entityDenotationSingular;
  final String entityDenotationPlural;
  final Function onSelectionConfirmed;

  const ImportSelectionListScreen(
      {Key? key,
      required this.bloc,
      required this.namedEntitySet,
      this.confirmationButtonLabel = "Import",
      required this.entityDenotationSingular,
      required this.entityDenotationPlural,
      required this.onSelectionConfirmed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionListScreen<N>(
        namedEntitySet: namedEntitySet,
        mainButtonLabel: confirmationButtonLabel,
        onMainButtonPressed: _onConfirmButtonPressed);
  }

  void _onConfirmButtonPressed(
      BuildContext context, List<N> sortedEntities, List<bool> isBoxSelected, int selectedBoxesCount) async {
    List<N> selectedEntities = _filterOutUnselectedEntities(sortedEntities, isBoxSelected);
    onSelectionConfirmed(selectedEntities);
  }

  List<N> _filterOutUnselectedEntities(List<N> sortedEntities, List<bool> isBoxSelected) {
    List<N> selectedEntities = [];
    for (int i = 0; i < sortedEntities.length; i++) {
      if (isBoxSelected[i]) {
        selectedEntities.add(sortedEntities[i]);
      }
    }
    return selectedEntities;
  }
}
