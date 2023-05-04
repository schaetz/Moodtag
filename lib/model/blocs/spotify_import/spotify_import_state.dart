import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

class SpotifyImportState extends Equatable {
  final SpotifyImportFlowStep step;
  final String? spotifyAuthCode;
  final bool doImportGenres;

  final UniqueNamedEntitySet<ImportedArtist>? availableSpotifyArtists;
  final UniqueNamedEntitySet<ImportedGenre>? availableGenresForSelectedArtists;
  final List<ImportedArtist>? selectedArtists;
  final List<ImportedGenre>? selectedGenres;

  const SpotifyImportState({
    this.step = SpotifyImportFlowStep.login,
    this.spotifyAuthCode,
    this.doImportGenres = false,
    this.availableSpotifyArtists,
    this.availableGenresForSelectedArtists,
    this.selectedArtists,
    this.selectedGenres,
  });

  @override
  List<Object?> get props => [
        step,
        spotifyAuthCode,
        doImportGenres,
        availableSpotifyArtists,
        availableGenresForSelectedArtists,
        selectedArtists,
        selectedGenres
      ];

  SpotifyImportState copyWith({
    SpotifyImportFlowStep? step,
    String? spotifyAuthCode,
    bool? doImportGenres,
    UniqueNamedEntitySet<ImportedArtist>? availableSpotifyArtists,
    UniqueNamedEntitySet<ImportedGenre>? availableGenresForSelectedArtists,
    List<ImportedArtist>? selectedArtists,
    List<ImportedGenre>? selectedGenres,
  }) {
    return SpotifyImportState(
      step: step ?? this.step,
      spotifyAuthCode: spotifyAuthCode ?? this.spotifyAuthCode,
      doImportGenres: doImportGenres ?? this.doImportGenres,
      availableSpotifyArtists: availableSpotifyArtists ?? this.availableSpotifyArtists,
      availableGenresForSelectedArtists: availableGenresForSelectedArtists ?? this.availableGenresForSelectedArtists,
      selectedArtists: selectedArtists ?? this.selectedArtists,
      selectedGenres: selectedGenres ?? this.selectedGenres,
    );
  }
}
