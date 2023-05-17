import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/artist_events.dart';
import '../error_stream_handling.dart';
import 'artists_list_state.dart';

class ArtistsListBloc extends Bloc<LibraryEvent, ArtistsListState> with ErrorStreamHandling {
  late final Repository _repository;
  late StreamSubscription _artistsStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  ArtistsListBloc(this._repository, BuildContext mainContext) : super(ArtistsListState()) {
    on<ArtistsListUpdated>(_mapArtistsListUpdatedEventToState);
    on<CreateArtists>(_mapCreateArtistsEventToState);
    on<DeleteArtist>(_mapDeleteArtistEventToState);
    on<ToggleTagSubtitles>(_mapToggleTagSubtitlesEventToState);
    on<ChangeArtistsListFilters>(_mapChangeArtistsListFiltersEventToState);

    _requestArtistsFromRepository();
    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _artistsStreamSubscription.cancel();
    super.close();
  }

  void _requestArtistsFromRepository({Set<Tag> filterTags = const {}}) {
    _artistsStreamSubscription = _repository
        .getArtistsWithTags(filterTags: filterTags)
        .handleError((error) => add(ArtistsListUpdated(error: error)))
        .listen((artistsListFromStream) => add(ArtistsListUpdated(artistsWithTags: artistsListFromStream)));
  }

  void _mapArtistsListUpdatedEventToState(ArtistsListUpdated event, Emitter<ArtistsListState> emit) {
    if (event.artistsWithTags != null) {
      emit(state.copyWith(artistsWithTags: event.artistsWithTags, loadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(loadingStatus: LoadingStatus.error));
    }
  }

  void _mapCreateArtistsEventToState(CreateArtists event, Emitter<ArtistsListState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateArtistsEvent(event, _repository);
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

  void _mapToggleTagSubtitlesEventToState(ToggleTagSubtitles event, Emitter<ArtistsListState> emit) {
    emit(state.copyWith(displayTagSubtitles: !state.displayTagSubtitles));
  }

  void _mapChangeArtistsListFiltersEventToState(ChangeArtistsListFilters event, Emitter<ArtistsListState> emit) {
    if (event.filterTags != state.filterTags) {
      _artistsStreamSubscription.cancel();
      _requestArtistsFromRepository(filterTags: event.filterTags);
      emit(state.copyWith(filterTags: event.filterTags, loadingStatus: LoadingStatus.loading));
    }
  }
}
