import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

class ImportFlowState {

  final UniqueNamedEntitySet<ImportedArtist> availableSpotifyArtists;
  final UniqueNamedEntitySet<ImportedGenre> importedArtistsGenres;
  final bool doImportGenres;
  final String spotifyAuthCode;
  final bool isArtistsImportFinished;
  final bool isGenresImportFinished;

  const ImportFlowState({this.availableSpotifyArtists, this.importedArtistsGenres,
    this.doImportGenres, this.spotifyAuthCode, this.isArtistsImportFinished, this.isGenresImportFinished
  });

  const ImportFlowState.initial({this.availableSpotifyArtists, this.importedArtistsGenres,
    this.doImportGenres: false, this.spotifyAuthCode: '', this.isArtistsImportFinished: false, this.isGenresImportFinished: false
  });

  ImportFlowState copyWith({
    UniqueNamedEntitySet<ImportedArtist> availableSpotifyArtists,
    UniqueNamedEntitySet<ImportedGenre> importedArtistsGenres,
    bool doImportGenres,
    String spotifyAuthCode,
    bool isArtistsImportFinished,
    bool isGenresImportFinished
  }) {
    return ImportFlowState(
      availableSpotifyArtists: availableSpotifyArtists ?? this.availableSpotifyArtists,
      importedArtistsGenres: importedArtistsGenres ?? this.importedArtistsGenres,
      doImportGenres: doImportGenres ?? this.doImportGenres,
      spotifyAuthCode: spotifyAuthCode ?? this.spotifyAuthCode,
      isArtistsImportFinished: isArtistsImportFinished ?? this.isArtistsImportFinished,
      isGenresImportFinished: isGenresImportFinished ?? this.isGenresImportFinished,
    );
  }
}