import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/events/library_event.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/artist_events.dart';
import '../error_stream_handling.dart';
import 'artists_list_state.dart';

class ArtistsListBloc extends Bloc<LibraryEvent, ArtistsListState> with ErrorStreamHandling {
  late final Repository _repository;
  late final StreamSubscription _artistsStreamSubscription;
  final CreateEntityBlocHelper createEntityBlocHelper = CreateEntityBlocHelper();

  ArtistsListBloc(this._repository, BuildContext mainContext) : super(ArtistsListState()) {
    on<ArtistsListUpdated>(_mapArtistsListUpdatedEventToState);
    on<CreateArtists>(_mapCreateArtistsEventToState);
    on<DeleteArtist>(_mapDeleteArtistEventToState);

    _artistsStreamSubscription = _repository
        .getArtists()
        .handleError((error) => add(ArtistsListUpdated(error: error)))
        .listen((artistsListFromStream) => add(ArtistsListUpdated(artists: artistsListFromStream)));

    setupErrorHandler(mainContext);
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

  void _mapCreateArtistsEventToState(CreateArtists event, Emitter<ArtistsListState> emit) async {
    final exception = await createEntityBlocHelper.handleCreateArtistsEvent(event, _repository);
    if (exception is NameAlreadyTakenException) {
      errorStreamController.add(exception);
    }
  }

  void _mapDeleteArtistEventToState(DeleteArtist event, Emitter<ArtistsListState> emit) async {
    final deleteArtistResponse = await _repository.deleteArtist(event.artist);
    if (deleteArtistResponse.didFail()) {
      errorStreamController.add(deleteArtistResponse.getUserFeedbackException());
    }
  }
}
