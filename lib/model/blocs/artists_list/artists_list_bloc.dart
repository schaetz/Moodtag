import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/artist_events.dart';
import '../loading_status.dart';
import 'artists_list_state.dart';

class ArtistsListBloc extends Bloc<ArtistEvent, ArtistsListState> {
  final Repository repository;

  ArtistsListBloc({this.repository}) : super(const ArtistsListState()) {
    on<OpenCreateArtistDialog>(_mapOpenCreateArtistDialogEventToState);
    on<CloseCreateArtistDialog>(_mapCloseCreateArtistDialogEventToState);
    on<GetArtists>(_mapGetArtistsEventToState);
    on<CreateArtist>(_mapCreateArtistEventToState);
    on<DeleteArtist>(_mapDeleteArtistEventToState);
  }

  void _mapOpenCreateArtistDialogEventToState(OpenCreateArtistDialog event, Emitter<ArtistsListState> emit) async {
    print('Open');
    if (!state.showCreateArtistDialog) emit(state.copyWith(showCreateArtistDialog: true));
  }

  void _mapCloseCreateArtistDialogEventToState(CloseCreateArtistDialog event, Emitter<ArtistsListState> emit) async {
    print('Close');
    if (state.showCreateArtistDialog) emit(state.copyWith(showCreateArtistDialog: false));
  }

  void _mapGetArtistsEventToState(GetArtists event, Emitter<ArtistsListState> emit) async {
    emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    try {
      final artists = await repository.getArtists();
      emit(
        state.copyWith(
          loadingStatus: LoadingStatus.success,
          artists: artists,
        ),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(loadingStatus: LoadingStatus.error));
    }
  }

  void _mapCreateArtistEventToState(CreateArtist event, Emitter<ArtistsListState> emit) {
    // TODO
  }

  void _mapDeleteArtistEventToState(DeleteArtist event, Emitter<ArtistsListState> emit) {
    // TODO
  }
}
