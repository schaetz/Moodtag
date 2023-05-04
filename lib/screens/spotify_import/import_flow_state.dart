import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';

class ImportFlowState extends Equatable {
  final SpotifyImportFlowStep step;

  const ImportFlowState({this.step = SpotifyImportFlowStep.login});

  @override
  List<Object?> get props => [step];

  ImportFlowState copyWith({SpotifyImportFlowStep? step}) {
    return ImportFlowState(step: step ?? this.step);
  }
}
