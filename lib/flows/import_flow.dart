import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/flows/import_flow_state.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/tag.dart';
import 'package:moodtag/screens/import_selection_list.dart';
import 'package:moodtag/screens/spotify_import.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';

class ImportFlow extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<ImportFlowState>(
      state: ImportFlowState.initial(),
      onGeneratePages: _onGenerateImportFlowPages,
    );
  }

  List<Page> _onGenerateImportFlowPages(ImportFlowState importFlowState, List<Page> pages) {
    return [
      MaterialPage<void>(child: SpotifyImportScreen(), name: '/spotifyImport'),
      if (importFlowState.importedArtistsSet != null) MaterialPage<void>(child: ImportSelectionListScreen<ImportedArtist,Artist>(
          entityDenotationSingular: Artist.denotationSingular,
          entityDenotationPlural: Artist.denotationPlural
      )),
      if (importFlowState.doImportGenres && importFlowState.isArtistsImportFinished) MaterialPage<void>(
        child: ImportSelectionListScreen<ImportedGenre,Tag>(
          entityDenotationSingular: "genre tag",
          entityDenotationPlural: "genre tags",
        )
      ),
    ];
  }

}