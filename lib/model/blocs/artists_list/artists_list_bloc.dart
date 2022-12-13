import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/events/LibraryEvent.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/artist_events.dart';
import 'artists_list_state.dart';

class ArtistsListBloc extends Bloc<LibraryEvent, ArtistsListState> {
  final Repository _repository;
  late final StreamSubscription _artistsStreamSubscription;
  final CreateEntityBlocHelper createEntityBlocHelper = CreateEntityBlocHelper();

  ArtistsListBloc(this._repository) : super(ArtistsListState()) {
    on<ArtistsListUpdated>(_mapArtistsListUpdatedEventToState);
    on<OpenCreateArtistDialog>(_mapOpenCreateArtistDialogEventToState);
    on<CloseCreateArtistDialog>(_mapCloseCreateArtistDialogEventToState);
    on<CreateArtists>(_mapCreateArtistsEventToState);
    on<DeleteArtist>(_mapDeleteArtistEventToState);

    _artistsStreamSubscription =
        _repository.getArtists().listen((artistsListFromStream) => add(ArtistsListUpdated(artistsListFromStream)));
  }

  Future<void> close() async {
    _artistsStreamSubscription.cancel();
    super.close();
  }

  void _mapArtistsListUpdatedEventToState(ArtistsListUpdated event, Emitter<ArtistsListState> emit) {
    if (event.artists != null) {
      emit(state.copyWith(artists: event.artists, loadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(loadingStatus: LoadingStatus.error));
    }
  }

  void _mapOpenCreateArtistDialogEventToState(OpenCreateArtistDialog event, Emitter<ArtistsListState> emit) {
    if (!state.showCreateArtistDialog) _openCreateArtistDialog(emit);
  }

  void _mapCloseCreateArtistDialogEventToState(CloseCreateArtistDialog event, Emitter<ArtistsListState> emit) {
    if (state.showCreateArtistDialog) _closeCreateArtistDialog(emit);
  }

  void _mapCreateArtistsEventToState(CreateArtists event, Emitter<ArtistsListState> emit) {
    createEntityBlocHelper.handleCreateArtistEvent(event, _repository);
    _closeCreateArtistDialog(emit);
  }

  void _mapDeleteArtistEventToState(DeleteArtist event, Emitter<ArtistsListState> emit) {
    // TODO
  }

  void _openCreateArtistDialog(Emitter<ArtistsListState> emit) {
    emit(state.copyWith(showCreateArtistDialog: true));
  }

  void _closeCreateArtistDialog(Emitter<ArtistsListState> emit) {
    emit(state.copyWith(showCreateArtistDialog: false));
  }
}
