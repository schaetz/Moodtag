import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_flow_step.dart';
import 'package:moodtag/screens/import_flow/abstract_import_flow_state.dart';

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
