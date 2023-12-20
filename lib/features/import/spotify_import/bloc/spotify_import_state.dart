import 'package:equatable/equatable.dart';
import 'package:moodtag/features/import/abstract_import_flow/bloc/abstract_import_state.dart';
import 'package:moodtag/features/import/spotify_import/config/spotify_import_option.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/structs/imported_entities/unique_import_entity_set.dart';

import '../flow/spotify_import_flow_step.dart';

class SpotifyImportState extends Equatable implements AbstractImportState {
  final SpotifyImportFlowStep step;
  final bool isFinished;
  final Map<SpotifyImportOption, bool> configuration;

  final UniqueImportEntitySet<SpotifyArtist>? availableSpotifyArtists;
  final UniqueImportEntitySet<ImportedTag>? availableGenresForSelectedArtists;
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
    UniqueImportEntitySet<SpotifyArtist>? availableSpotifyArtists,
    UniqueImportEntitySet<ImportedTag>? availableGenresForSelectedArtists,
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
