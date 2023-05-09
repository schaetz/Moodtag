import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/screens/spotify_import/spotify_connector.dart';
import 'package:moodtag/screens/spotify_import/spotify_import_config_screen.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

class SpotifyImportState extends Equatable {
  final SpotifyImportFlowStep step;
  final String? spotifyAuthCode;
  final SpotifyAccessToken? spotifyAccessToken;
  final Map<SpotifyImportOption, bool> configuration;

  final UniqueNamedEntitySet<ImportedArtist>? availableSpotifyArtists;
  final UniqueNamedEntitySet<ImportedGenre>? availableGenresForSelectedArtists;
  final List<ImportedArtist>? selectedArtists;
  final List<ImportedGenre>? selectedGenres;

  const SpotifyImportState({
    this.step = SpotifyImportFlowStep.login,
    this.spotifyAuthCode,
    this.spotifyAccessToken,
    this.configuration = const {},
    this.availableSpotifyArtists,
    this.availableGenresForSelectedArtists,
    this.selectedArtists,
    this.selectedGenres,
  });

  @override
  List<Object?> get props => [
        step,
        spotifyAuthCode,
        spotifyAccessToken,
        configuration,
        availableSpotifyArtists,
        availableGenresForSelectedArtists,
        selectedArtists,
        selectedGenres
      ];

  bool get isConfigurationValid => configuration.values.where((selection) => selection == true).toList().isNotEmpty;
  bool get doImportGenres => configuration[SpotifyImportOption.artistGenres] == true;

  SpotifyImportState copyWith({
    SpotifyImportFlowStep? step,
    String? spotifyAuthCode,
    SpotifyAccessToken? spotifyAccessToken,
    Map<SpotifyImportOption, bool>? configuration,
    UniqueNamedEntitySet<ImportedArtist>? availableSpotifyArtists,
    UniqueNamedEntitySet<ImportedGenre>? availableGenresForSelectedArtists,
    List<ImportedArtist>? selectedArtists,
    List<ImportedGenre>? selectedGenres,
  }) {
    return SpotifyImportState(
      step: step ?? this.step,
      spotifyAuthCode: spotifyAuthCode ?? this.spotifyAuthCode,
      spotifyAccessToken: spotifyAccessToken ?? this.spotifyAccessToken,
      configuration: configuration ?? this.configuration,
      availableSpotifyArtists: availableSpotifyArtists ?? this.availableSpotifyArtists,
      availableGenresForSelectedArtists: availableGenresForSelectedArtists ?? this.availableGenresForSelectedArtists,
      selectedArtists: selectedArtists ?? this.selectedArtists,
      selectedGenres: selectedGenres ?? this.selectedGenres,
    );
  }
}
