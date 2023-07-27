import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/screens/import_flow/abstract_import_flow_state.dart';

class SpotifyImportFlowState extends AbstractImportFlowState {
  final SpotifyImportFlowStep step;
  final bool doShowGenreImportScreen;

  SpotifyImportFlowState({this.step = SpotifyImportFlowStep.config, this.doShowGenreImportScreen = false});

  @override
  List<Object?> get props => [step, doShowGenreImportScreen];

  SpotifyImportFlowState copyWith({SpotifyImportFlowStep? step, bool? doShowGenreImportScreen, bool? flowCancelled}) {
    return SpotifyImportFlowState(
      step: step ?? this.step,
      doShowGenreImportScreen: doShowGenreImportScreen ?? this.doShowGenreImportScreen,
    );
  }
}
