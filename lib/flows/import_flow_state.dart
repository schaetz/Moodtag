import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

class ImportFlowState {

  const ImportFlowState({this.importedArtistsSet,
    this.doImportGenres, this.isArtistsImportFinished, this.isGenresImportFinished
  });

  const ImportFlowState.initial({this.importedArtistsSet,
    this.doImportGenres: false, this.isArtistsImportFinished: false, this.isGenresImportFinished: false
  });

  final UniqueNamedEntitySet<ImportedArtist> importedArtistsSet;
  final bool doImportGenres;
  final bool isArtistsImportFinished;
  final bool isGenresImportFinished;

  ImportFlowState copyWith({UniqueNamedEntitySet<ImportedArtist> importedArtistsSet, bool doImportGenres,
    bool isArtistsImportFinished, bool isGenresImportFinished
  }) {
    return ImportFlowState(
      importedArtistsSet: importedArtistsSet ?? this.importedArtistsSet,
      doImportGenres: doImportGenres ?? this.doImportGenres,
      isArtistsImportFinished: isArtistsImportFinished ?? this.isArtistsImportFinished,
      isGenresImportFinished: isGenresImportFinished ?? this.isGenresImportFinished,
    );
  }
}