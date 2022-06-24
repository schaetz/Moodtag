import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/flows/import_flow_state.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/screens/import_selection_list.dart';
import 'package:moodtag/screens/spotify_import.dart';
import 'package:moodtag/screens/spotify_login_webview.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';
import 'package:moodtag/utils/entity_creator.dart';
import 'package:moodtag/utils/i10n.dart';

class ImportFlow extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<ImportFlowState>(
      state: ImportFlowState.initial(),
      onGeneratePages: _onGenerateImportFlowPages,
      onComplete: (importFlowState) => _completeFlow(context, importFlowState),
    );
  }

  List<Page> _onGenerateImportFlowPages(ImportFlowState importFlowState, List<Page> pages) {
    if (importFlowState.spotifyAuthCode.isEmpty) {
      return [
        MaterialPage<void>(
          child: SpotifyLoginWebview(),
        )
      ];
    }

    return [
      MaterialPage<void>(child: SpotifyImportScreen(), name: Routes.spotifyImport),
      if (importFlowState.availableSpotifyArtists != null) MaterialPage<void>(
        child: ImportSelectionListScreen<ImportedArtist>(
          namedEntitySet: importFlowState.availableSpotifyArtists,
          confirmationButtonLabel: importFlowState.doImportGenres ? "OK" : "Import",
          entityDenotationSingular: I10n.ARTIST_DENOTATION_SINGULAR,
          entityDenotationPlural: I10n.ARTIST_DENOTATION_PLURAL,
        )
      ),
      if (importFlowState.doImportGenres && importFlowState.isArtistsSelectionFinished) MaterialPage<void>(
        child: ImportSelectionListScreen<ImportedGenre>(
          namedEntitySet: importFlowState.availableArtistsGenres,
          confirmationButtonLabel: "Import",
          entityDenotationSingular: "genre tag",
          entityDenotationPlural: "genre tags",
        )
      ),
    ];
  }

  void _completeFlow(BuildContext context, ImportFlowState importFlowState) async {
    if (importFlowState.isArtistsSelectionFinished && (!importFlowState.doImportGenres || importFlowState.isGenresSelectionFinished)) {
      List<NamedEntity> entitiesToCreate = [];
      entitiesToCreate.addAll(importFlowState.selectedArtists);
      entitiesToCreate.addAll(importFlowState.selectedGenres);

      final Map<Type, DbRequestSuccessCounter> creationSuccessCountersByType = await createEntities(
          context, entitiesToCreate);
      _showResultMessage(context, creationSuccessCountersByType);
    }

    Navigator.of(context).popUntil(ModalRouteExt.withNames(Routes.artistsList, Routes.tagsList));
  }

  void _showResultMessage(BuildContext context, Map<Type,DbRequestSuccessCounter> creationSuccessCountersByType) {
    String message;

    if (creationSuccessCountersByType[ImportedArtist].successCount > 0) {
      if (creationSuccessCountersByType[ImportedGenre].successCount > 0) {
        message = """
        Successfully added ${creationSuccessCountersByType[ImportedArtist].successCount} artists and
        ${creationSuccessCountersByType[ImportedGenre].successCount} tags.
        """;
      } else {
        message = "Successfully added ${creationSuccessCountersByType[ImportedArtist].successCount} artists.";
      }
    } else if (creationSuccessCountersByType[ImportedGenre].successCount > 0) {
      message = "Successfully added ${creationSuccessCountersByType[ImportedGenre].successCount} genres.";
    } else {
      message = "No entities were added.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

}