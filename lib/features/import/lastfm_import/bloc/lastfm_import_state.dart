import 'package:equatable/equatable.dart';
import 'package:moodtag/features/import/abstract_import_flow/bloc/abstract_import_state.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_config.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/shared/models/structs/imported_entities/lastfm_artist.dart';
import 'package:moodtag/shared/models/structs/imported_entities/unique_import_entity_set.dart';

import '../flow/lastfm_import_flow_step.dart';

class LastFmImportState extends Equatable implements AbstractImportState {
  final bool isInitialized;
  final LastFmImportFlowStep step;
  final bool isFinished;
  final LastFmImportConfig? importConfig;

  // We are not using the LibraryUserBlocMixin for this bloc as we don't need to update the screen when entities change
  final LoadedData<List<TagCategoryData>> allTagCategories;
  final LoadedData<List<Tag>> allTags;

  final UniqueImportEntitySet<LastFmArtist>? availableLastFmArtists;
  final List<LastFmArtist>? selectedArtists;

  const LastFmImportState({
    this.isInitialized = false,
    this.step = LastFmImportFlowStep.config,
    this.isFinished = false,
    this.importConfig,
    this.allTagCategories = const LoadedData.loading(),
    this.allTags = const LoadedData.loading(),
    this.availableLastFmArtists,
    this.selectedArtists,
  });

  @override
  List<Object?> get props => [
        isInitialized,
        step,
        isFinished,
        importConfig,
        allTagCategories,
        allTags,
        availableLastFmArtists,
        selectedArtists,
      ];

  LastFmImportState copyWith({
    bool? isInitialized,
    LastFmImportFlowStep? step,
    bool? isFinished,
    LastFmImportConfig? importConfig,
    LoadedData<List<TagCategoryData>>? allTagCategories,
    LoadedData<List<Tag>>? allTags,
    UniqueImportEntitySet<LastFmArtist>? availableLastFmArtists,
    List<LastFmArtist>? selectedArtists,
  }) {
    return LastFmImportState(
      isInitialized: isInitialized ?? this.isInitialized,
      step: step ?? this.step,
      isFinished: isFinished ?? this.isFinished,
      importConfig: importConfig ?? this.importConfig,
      allTagCategories: allTagCategories ?? this.allTagCategories,
      allTags: allTags ?? this.allTags,
      availableLastFmArtists: availableLastFmArtists ?? this.availableLastFmArtists,
      selectedArtists: selectedArtists ?? this.selectedArtists,
    );
  }
}
