import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_state.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_option.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

import 'spotify_import_flow_step.dart';

class SpotifyImportState extends Equatable implements AbstractImportState {
  final SpotifyImportFlowStep step;
  final bool isFinished;
  final Map<SpotifyImportOption, bool> configuration;

  final UniqueNamedEntitySet<SpotifyArtist>? availableSpotifyArtists;
  final UniqueNamedEntitySet<ImportedTag>? availableGenresForSelectedArtists;
  final List<SpotifyArtist>? selectedArtists;
  final List<ImportedTag>? selectedGenres;

  const SpotifyImportState({
    this.step = SpotifyImportFlowStep.config,
    this.isFinished = false,
    this.configuration = const {},
    this.availableSpotifyArtists,
    this.availableGenresForSelectedArtists,
    this.selectedArtists,
    this.selectedGenres,
  });

  @override
  List<Object?> get props => [
        step,
        isFinished,
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
    bool? isFinished,
    Map<SpotifyImportOption, bool>? configuration,
    UniqueNamedEntitySet<SpotifyArtist>? availableSpotifyArtists,
    UniqueNamedEntitySet<ImportedTag>? availableGenresForSelectedArtists,
    List<SpotifyArtist>? selectedArtists,
    List<ImportedTag>? selectedGenres,
  }) {
    return SpotifyImportState(
      step: step ?? this.step,
      isFinished: isFinished ?? this.isFinished,
      configuration: configuration ?? this.configuration,
      availableSpotifyArtists: availableSpotifyArtists ?? this.availableSpotifyArtists,
      availableGenresForSelectedArtists: availableGenresForSelectedArtists ?? this.availableGenresForSelectedArtists,
      selectedArtists: selectedArtists ?? this.selectedArtists,
      selectedGenres: selectedGenres ?? this.selectedGenres,
    );
  }
}
