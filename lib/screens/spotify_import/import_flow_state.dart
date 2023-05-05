import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';

class ImportFlowState extends Equatable {
  final SpotifyImportFlowStep step;
  final bool doShowGenreImportScreen;

  const ImportFlowState({this.step = SpotifyImportFlowStep.login, this.doShowGenreImportScreen = false});

  @override
  List<Object?> get props => [step, doShowGenreImportScreen];

  ImportFlowState copyWith({SpotifyImportFlowStep? step, bool? doShowGenreImportScreen}) {
    return ImportFlowState(
        step: step ?? this.step, doShowGenreImportScreen: doShowGenreImportScreen ?? this.doShowGenreImportScreen);
  }
}
