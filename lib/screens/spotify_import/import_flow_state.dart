import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';

class ImportFlowState extends Equatable {
  final SpotifyImportFlowStep step;
  final bool doShowGenreImportScreen;
  final bool flowCancelled;

  const ImportFlowState(
      {this.step = SpotifyImportFlowStep.login, this.doShowGenreImportScreen = false, this.flowCancelled = false});

  @override
  List<Object?> get props => [step, doShowGenreImportScreen, flowCancelled];

  ImportFlowState copyWith({SpotifyImportFlowStep? step, bool? doShowGenreImportScreen, bool? flowCancelled}) {
    return ImportFlowState(
        step: step ?? this.step,
        doShowGenreImportScreen: doShowGenreImportScreen ?? this.doShowGenreImportScreen,
        flowCancelled: flowCancelled ?? this.flowCancelled);
  }
}
