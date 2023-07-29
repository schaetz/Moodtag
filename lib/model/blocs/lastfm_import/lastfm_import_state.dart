import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_state.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_option.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/lastfm_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

import 'lastfm_import_flow_step.dart';

class LastFmImportState extends Equatable implements AbstractImportState {
  final LastFmImportFlowStep step;
  final bool isFinished;
  final Map<LastFmImportOption, bool> configuration;

  final UniqueNamedEntitySet<LastFmArtist>? availableLastFmArtists;
  final UniqueNamedEntitySet<ImportedTag>? availableTagsForSelectedArtists;
  final List<LastFmArtist>? selectedArtists;
  final List<ImportedTag>? selectedTags;

  const LastFmImportState({
    this.step = LastFmImportFlowStep.config,
    this.isFinished = false,
    this.configuration = const {},
    this.availableLastFmArtists,
    this.availableTagsForSelectedArtists,
    this.selectedArtists,
    this.selectedTags,
  });

  @override
  List<Object?> get props => [
        step,
        isFinished,
        configuration,
        availableLastFmArtists,
        availableTagsForSelectedArtists,
        selectedArtists,
        selectedTags
      ];

  bool get isConfigurationValid => configuration.values.where((selection) => selection == true).toList().isNotEmpty;

  LastFmImportState copyWith({
    LastFmImportFlowStep? step,
    bool? isFinished,
    Map<LastFmImportOption, bool>? configuration,
    UniqueNamedEntitySet<LastFmArtist>? availableLastFmArtists,
    UniqueNamedEntitySet<ImportedTag>? availableTagsForSelectedArtists,
    List<LastFmArtist>? selectedArtists,
    List<ImportedTag>? selectedTags,
  }) {
    return LastFmImportState(
      step: step ?? this.step,
      isFinished: isFinished ?? this.isFinished,
      configuration: configuration ?? this.configuration,
      availableLastFmArtists: availableLastFmArtists ?? this.availableLastFmArtists,
      availableTagsForSelectedArtists: availableTagsForSelectedArtists ?? this.availableTagsForSelectedArtists,
      selectedArtists: selectedArtists ?? this.selectedArtists,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}
