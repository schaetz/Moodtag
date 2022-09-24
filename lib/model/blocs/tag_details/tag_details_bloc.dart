import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/events/LibraryEvent.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'tag_details_state.dart';

class TagDetailsBloc extends Bloc<LibraryEvent, TagDetailsState> {
  final Repository _repository;
  StreamSubscription _tagStreamSubscription;
  StreamSubscription _artistsWithTagStreamSubscription;

  TagDetailsBloc(this._repository, int tagId) : super(TagDetailsState(tagId: tagId)) {
    on<TagUpdated>(_mapTagUpdatedEventToState);
    on<ArtistsListUpdated>(_mapArtistsListUpdatedEventToState);

    _tagStreamSubscription =
        _repository.getArtistById(tagId).listen((artistFromStream) => add(TagUpdated(artistFromStream)));
    _artistsWithTagStreamSubscription =
        _repository.getTagsForArtist(tagId).listen((tagsListFromStream) => add(ArtistsListUpdated(tagsListFromStream)));
  }

  Future<void> close() async {
    _tagStreamSubscription.cancel();
    _artistsWithTagStreamSubscription.cancel();
    super.close();
  }

  void _mapTagUpdatedEventToState(TagUpdated event, Emitter<TagDetailsState> emit) {
    if (event.tag != null) {
      emit(state.copyWith(tag: event.tag, tagLoadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(tagLoadingStatus: LoadingStatus.error));
    }
  }

  void _mapArtistsListUpdatedEventToState(ArtistsListUpdated event, Emitter<TagDetailsState> emit) {
    if (event.artists != null) {
      emit(state.copyWith(artistsWithTag: event.artists, artistsListLoadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(artistsListLoadingStatus: LoadingStatus.error));
    }
  }
}
