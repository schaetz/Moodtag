import '../spotify_import/spotify_import_bloc.dart';

abstract class AbstractImportState {
  SpotifyImportFlowStep get step;
}
