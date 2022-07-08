import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/screens/selection_list_screen.dart';
import 'package:moodtag/screens/spotify_import/import_flow_state.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

class ImportSelectionListScreen<N extends NamedEntity> extends StatelessWidget {
  final UniqueNamedEntitySet<N> namedEntitySet;
  final String confirmationButtonLabel;
  final String entityDenotationSingular;
  final String entityDenotationPlural;

  const ImportSelectionListScreen(
      {Key key,
      this.namedEntitySet,
      this.confirmationButtonLabel = "Import",
      this.entityDenotationSingular,
      this.entityDenotationPlural})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionListScreen<N>(
        namedEntitySet: namedEntitySet,
        mainButtonLabel: confirmationButtonLabel,
        onMainButtonPressed: _onImportButtonPressed);
  }

  void _onImportButtonPressed(
      BuildContext context, List<N> sortedEntities, List<bool> isBoxSelected, int selectedBoxesCount) async {
    if (selectedBoxesCount == 0) {
      _showNoSelectionError(context);
    } else {
      List<N> selectedEntities = _filterOutUnselectedEntities(sortedEntities, isBoxSelected);
      _advanceImportFlowState(context, selectedEntities);
    }
  }

  void _showNoSelectionError(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("No $entityDenotationPlural selected for import.")));
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

  void _advanceImportFlowState(BuildContext context, List<N> selectedEntities) {
    final flowController = context.flow<ImportFlowState>();
    if (N == ImportedArtist) {
      flowController.update((state) => state.copyWith(
            isArtistsSelectionFinished: true,
            selectedArtists: selectedEntities as List<ImportedArtist>,
            availableArtistsGenres: _getImportedArtistsGenres(selectedEntities as List<ImportedArtist>),
          ));
    } else if (N == ImportedGenre) {
      flowController.update((state) => state.copyWith(
            isGenresSelectionFinished: true,
            selectedGenres: selectedEntities as List<ImportedGenre>,
          ));
    } else {
      throw new UnimplementedError("The functionality for importing an entity of type $N is not implemented yet.");
    }

    if (flowController.state.isArtistsSelectionFinished &&
        (!flowController.state.doImportGenres || flowController.state.isGenresSelectionFinished)) {
      flowController.complete();
    }
  }

  UniqueNamedEntitySet<ImportedGenre> _getImportedArtistsGenres(List<ImportedArtist> sortedEntities) {
    final UniqueNamedEntitySet<ImportedGenre> importedArtistsGenres = UniqueNamedEntitySet();
    sortedEntities.forEach((importedArtist) {
      List<ImportedGenre> genresList = importedArtist.genres.map((genreName) => ImportedGenre(genreName)).toList();
      genresList.forEach((genreEntity) => importedArtistsGenres.add(genreEntity));
    });
    return importedArtistsGenres;
  }
}
