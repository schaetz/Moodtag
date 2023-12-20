import 'package:moodtag/features/import/abstract_import_flow/flow/abstract_import_flow_state.dart';
import 'package:moodtag/features/import/lastfm_import/flow/lastfm_import_flow_step.dart';

class LastFmImportFlowState extends AbstractImportFlowState {
  final LastFmImportFlowStep step;

  LastFmImportFlowState({this.step = LastFmImportFlowStep.config});

  @override
  List<Object?> get props => [step];

  LastFmImportFlowState copyWith({LastFmImportFlowStep? step}) {
    return LastFmImportFlowState(
      step: step ?? this.step,
    );
  }
}
