import 'package:moodtag/features/import/import_flow/abstract_import_flow_state.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_flow_step.dart';

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
