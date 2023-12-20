import 'package:moodtag/features/import/abstract_import_flow/flow/abstract_import_flow_state.dart';
import 'package:moodtag/features/import/spotify_import/flow/spotify_import_flow_step.dart';

class SpotifyImportFlowState extends AbstractImportFlowState {
  final SpotifyImportFlowStep step;

  SpotifyImportFlowState({this.step = SpotifyImportFlowStep.config});

  @override
  List<Object?> get props => [step];

  SpotifyImportFlowState copyWith({SpotifyImportFlowStep? step}) {
    return SpotifyImportFlowState(
      step: step ?? this.step,
    );
  }
}
