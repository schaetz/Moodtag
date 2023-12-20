import 'package:equatable/equatable.dart';
import 'package:moodtag/features/import/abstract_import_flow/bloc/abstract_import_state.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_option.dart';
import 'package:moodtag/structs/imported_entities/lastfm_artist.dart';
import 'package:moodtag/structs/imported_entities/unique_import_entity_set.dart';

import '../flow/lastfm_import_flow_step.dart';

class LastFmImportState extends Equatable implements AbstractImportState {
  final LastFmImportFlowStep step;
  final bool isFinished;
  final Map<LastFmImportOption, bool> configuration;

  final UniqueImportEntitySet<LastFmArtist>? availableLastFmArtists;
  final List<LastFmArtist>? selectedArtists;

  const LastFmImportState({
    this.step = LastFmImportFlowStep.config,
    this.isFinished = false,
    this.configuration = const {},
    this.availableLastFmArtists,
    this.selectedArtists,
  });

  @override
  List<Object?> get props => [
        step,
        isFinished,
        configuration,
        availableLastFmArtists,
        selectedArtists,
      ];

  bool get isConfigurationValid =>
      configuration[LastFmImportOption.allTimeTopArtists] == true ||
      configuration[LastFmImportOption.lastMonthTopArtists] == true;

  LastFmImportState copyWith({
    LastFmImportFlowStep? step,
    bool? isFinished,
    Map<LastFmImportOption, bool>? configuration,
    UniqueImportEntitySet<LastFmArtist>? availableLastFmArtists,
    List<LastFmArtist>? selectedArtists,
  }) {
    return LastFmImportState(
      step: step ?? this.step,
      isFinished: isFinished ?? this.isFinished,
      configuration: configuration ?? this.configuration,
      availableLastFmArtists: availableLastFmArtists ?? this.availableLastFmArtists,
      selectedArtists: selectedArtists ?? this.selectedArtists,
    );
  }
}
