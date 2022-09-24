import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_artist_bloc_helper.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/events/LibraryEvent.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'artist_details_state.dart';

class ArtistDetailsBloc extends Bloc<LibraryEvent, ArtistDetailsState> {
  final Repository _repository;
  StreamSubscription _artistStreamSubscription;
  StreamSubscription _tagsForArtistStreamSubscription;
  final CreateArtistBlocHelper createArtistBlocHelper = CreateArtistBlocHelper();

  ArtistDetailsBloc(this._repository, int artistId)
      : super(ArtistDetailsState(artistId: artistId, tagEditMode: false)) {
    on<ArtistUpdated>(_mapArtistUpdatedEventToState);
    on<TagsListUpdated>(_mapTagsListUpdatedEventToState);
    on<ToggleTagEditMode>(_mapToggleTagEditModeEventToState);
    on<CreateArtists>(_mapCreateArtistsEventToState);

    _artistStreamSubscription =
        _repository.getArtistById(artistId).listen((artistFromStream) => add(ArtistUpdated(artistFromStream)));
    _tagsForArtistStreamSubscription =
        _repository.getTagsForArtist(artistId).listen((tagsListFromStream) => add(TagsListUpdated(tagsListFromStream)));
  }

  Future<void> close() async {
    _artistStreamSubscription.cancel();
    _tagsForArtistStreamSubscription.cancel();
    super.close();
  }

  void _mapArtistUpdatedEventToState(ArtistUpdated event, Emitter<ArtistDetailsState> emit) {
    if (event.artist != null) {
      emit(state.copyWith(artist: event.artist, artistLoadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(artistLoadingStatus: LoadingStatus.error));
    }
  }

  void _mapTagsListUpdatedEventToState(TagsListUpdated event, Emitter<ArtistDetailsState> emit) {
    if (event.tags != null) {
      emit(state.copyWith(tagsForArtist: event.tags, tagsListLoadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(tagsListLoadingStatus: LoadingStatus.error));
    }
  }

  void _mapToggleTagEditModeEventToState(ToggleTagEditMode event, Emitter<ArtistDetailsState> emit) {
    emit(state.copyWith(tagEditMode: !state.tagEditMode));
  }

  void _mapCreateArtistsEventToState(CreateArtists event, Emitter<ArtistDetailsState> emit) async {
    await createArtistBlocHelper.handleCreateArtistEvent(event, _repository);
  }
}
