import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

class ImportFlowState {
  final UniqueNamedEntitySet<ImportedArtist> availableSpotifyArtists;
  final UniqueNamedEntitySet<ImportedGenre> availableArtistsGenres;
  final List<ImportedArtist> selectedArtists;
  final List<ImportedGenre> selectedGenres;
  final bool doImportGenres;
  final String spotifyAuthCode;
  final bool isArtistsSelectionFinished;
  final bool isGenresSelectionFinished;

  const ImportFlowState(
      {this.availableSpotifyArtists,
      this.availableArtistsGenres,
      this.selectedArtists,
      this.selectedGenres,
      this.doImportGenres,
      this.spotifyAuthCode,
      this.isArtistsSelectionFinished,
      this.isGenresSelectionFinished});

  const ImportFlowState.initial(
      {this.availableSpotifyArtists,
      this.availableArtistsGenres,
      this.selectedArtists,
      this.selectedGenres,
      this.doImportGenres: false,
      this.spotifyAuthCode: '',
      this.isArtistsSelectionFinished: false,
      this.isGenresSelectionFinished: false});

  ImportFlowState copyWith(
      {UniqueNamedEntitySet<ImportedArtist> availableSpotifyArtists,
      UniqueNamedEntitySet<ImportedGenre> availableArtistsGenres,
      List<ImportedArtist> selectedArtists,
      List<ImportedGenre> selectedGenres,
      bool doImportGenres,
      String spotifyAuthCode,
      bool isArtistsSelectionFinished,
      bool isGenresSelectionFinished}) {
    return ImportFlowState(
      availableSpotifyArtists: availableSpotifyArtists ?? this.availableSpotifyArtists,
      availableArtistsGenres: availableArtistsGenres ?? this.availableArtistsGenres,
      selectedArtists: selectedArtists ?? this.selectedArtists,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      doImportGenres: doImportGenres ?? this.doImportGenres,
      spotifyAuthCode: spotifyAuthCode ?? this.spotifyAuthCode,
      isArtistsSelectionFinished: isArtistsSelectionFinished ?? this.isArtistsSelectionFinished,
      isGenresSelectionFinished: isGenresSelectionFinished ?? this.isGenresSelectionFinished,
    );
  }
}
