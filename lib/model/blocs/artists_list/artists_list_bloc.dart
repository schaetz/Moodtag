import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_artist_bloc_helper.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/artist_events.dart';
import '../loading_status.dart';
import 'artists_list_state.dart';

class ArtistsListBloc extends Bloc<ArtistEvent, ArtistsListState> {
  final Repository repository;
  final CreateArtistBlocHelper createArtistBlocHelper = CreateArtistBlocHelper();

  ArtistsListBloc({this.repository}) : super(const ArtistsListState()) {
    on<OpenCreateArtistDialog>(_mapOpenCreateArtistDialogEventToState);
    on<CloseCreateArtistDialog>(_mapCloseCreateArtistDialogEventToState);
    on<GetArtists>(_mapGetArtistsEventToState);
    on<CreateArtists>(_mapCreateArtistsEventToState);
    on<DeleteArtist>(_mapDeleteArtistEventToState);
  }

  void _mapOpenCreateArtistDialogEventToState(OpenCreateArtistDialog event, Emitter<ArtistsListState> emit) {
    print('Open');
    if (!state.showCreateArtistDialog) _openCreateArtistDialog();
  }

  void _mapCloseCreateArtistDialogEventToState(CloseCreateArtistDialog event, Emitter<ArtistsListState> emit) {
    print('Close');
    if (state.showCreateArtistDialog) _closeCreateArtistDialog();
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

  void _mapCreateArtistsEventToState(CreateArtists event, Emitter<ArtistsListState> emit) async {
    await createArtistBlocHelper.handleCreateArtistEvent(event, repository);
    _closeCreateArtistDialog();
  }

  void _mapDeleteArtistEventToState(DeleteArtist event, Emitter<ArtistsListState> emit) {
    // TODO
  }

  void _openCreateArtistDialog() {
    emit(state.copyWith(showCreateArtistDialog: true));
  }

  void _closeCreateArtistDialog() {
    emit(state.copyWith(showCreateArtistDialog: false));
  }
}
