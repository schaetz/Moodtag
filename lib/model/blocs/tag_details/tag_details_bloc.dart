import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/library_event.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'tag_details_state.dart';

class TagDetailsBloc extends Bloc<LibraryEvent, TagDetailsState> with ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _tagStreamSubscription;
  late final StreamSubscription _artistsWithTagStreamSubscription;

  TagDetailsBloc(this._repository, BuildContext mainContext, int tagId)
      : super(TagDetailsState(tagId: tagId, tagEditMode: false)) {
    on<TagUpdated>(_mapTagUpdatedEventToState);
    on<ArtistsListUpdated>(_mapArtistsListUpdatedEventToState);

    _tagStreamSubscription = _repository
        .getArtistById(tagId)
        .handleError((error) => add(TagUpdated(error: error)))
        .listen((tagFromStream) => add(TagUpdated(tag: tagFromStream)));
    _artistsWithTagStreamSubscription = _repository
        .getArtistsWithTag(tagId)
        .handleError((error) => add(ArtistsListUpdated(error: error)))
        .listen((artistsListFromStream) => add(ArtistsListUpdated(artists: artistsListFromStream)));

    setupErrorHandler(mainContext);
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
