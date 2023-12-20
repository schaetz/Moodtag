import 'package:moodtag/features/import/import_flow/abstract_import_flow_state.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_flow_step.dart';

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
