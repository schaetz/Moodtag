import 'package:equatable/equatable.dart';
import 'package:moodtag/features/import/abstract_import_flow/bloc/abstract_import_state.dart';
import 'package:moodtag/features/import/spotify_import/config/spotify_import_config.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/shared/models/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/shared/models/structs/imported_entities/unique_import_entity_set.dart';

import '../flow/spotify_import_flow_step.dart';

class SpotifyImportState extends Equatable implements AbstractImportState {
  final bool isInitialized;
  final SpotifyImportFlowStep step;
  final bool isFinished;
  final SpotifyImportConfig? _importConfig;
  @override
  SpotifyImportConfig? get importConfig => _importConfig;

  // We are not using the LibraryUserBlocMixin for this bloc as we don't need to update the screen when entities change
  final LoadedData<List<TagCategory>> allTagCategories;
  final LoadedData<List<Tag>> allTags;

  final UniqueImportEntitySet<SpotifyArtist>? availableSpotifyArtists;
  final UniqueImportEntitySet<ImportedTag>? availableGenresForSelectedArtists;
  final List<SpotifyArtist>? selectedArtists;
  final List<ImportedTag>? selectedGenres;

  const SpotifyImportState({
    this.isInitialized = false,
    this.step = SpotifyImportFlowStep.config,
    this.isFinished = false,
    final SpotifyImportConfig? importConfigVal,
    this.allTagCategories = const LoadedData.loading(),
    this.allTags = const LoadedData.loading(),
    this.availableSpotifyArtists,
    this.availableGenresForSelectedArtists,
    this.selectedArtists,
    this.selectedGenres,
  }) : this._importConfig = importConfigVal;

  @override
  List<Object?> get props => [
        isInitialized,
        step,
        isFinished,
        importConfig,
        allTagCategories,
        allTags,
        availableSpotifyArtists,
        availableGenresForSelectedArtists,
        selectedArtists,
        selectedGenres
      ];

  SpotifyImportState copyWith({
    bool? isInitialized,
    SpotifyImportFlowStep? step,
    bool? isFinished,
    SpotifyImportConfig? importConfig,
    LoadedData<List<TagCategory>>? allTagCategories,
    LoadedData<List<Tag>>? allTags,
    UniqueImportEntitySet<SpotifyArtist>? availableSpotifyArtists,
    UniqueImportEntitySet<ImportedTag>? availableGenresForSelectedArtists,
    List<SpotifyArtist>? selectedArtists,
    List<ImportedTag>? selectedGenres,
  }) {
    return SpotifyImportState(
      step: step ?? this.step,
      isFinished: isFinished ?? this.isFinished,
      importConfigVal: importConfig ?? this.importConfig,
      allTagCategories: allTagCategories ?? this.allTagCategories,
      allTags: allTags ?? this.allTags,
      availableSpotifyArtists: availableSpotifyArtists ?? this.availableSpotifyArtists,
      availableGenresForSelectedArtists: availableGenresForSelectedArtists ?? this.availableGenresForSelectedArtists,
      selectedArtists: selectedArtists ?? this.selectedArtists,
      selectedGenres: selectedGenres ?? this.selectedGenres,
    );
  }
}
