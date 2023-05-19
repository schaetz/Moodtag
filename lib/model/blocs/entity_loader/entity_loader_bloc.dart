import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loaded_object.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';

class EntityLoaderBloc extends Bloc<LibraryEvent, EntityLoaderState> {
  late final Repository _repository;
  late StreamSubscription _artistsStreamSubscription;
  late StreamSubscription _tagsStreamSubscription;

  EntityLoaderBloc(this._repository) : super(EntityLoaderState.initial()) {
    on<StartedLoading>(_handleStartedLoading);
    on<ArtistsListUpdated>(_handleArtistsListUpdated);
    on<TagsListUpdated>(_handleTagsListUpdated);

    _artistsStreamSubscription = _repository
        .getArtistsWithTags()
        .handleError((error) => add(ArtistsListUpdated(error: error)))
        .listen((artistsListFromStream) => add(ArtistsListUpdated(artistsWithTags: artistsListFromStream)));
    add(StartedLoading(List<ArtistData>));

    _tagsStreamSubscription = _repository
        .getTagsWithArtistFreq()
        .handleError((error) => add(TagsListUpdated(error: error)))
        .listen((tagsListFromStream) => add(TagsListUpdated(tags: tagsListFromStream)));
    add(StartedLoading(List<Tag>));
  }

  @override
  Future<void> close() async {
    _artistsStreamSubscription.cancel();
    _tagsStreamSubscription.cancel();
    super.close();
  }

  void _handleStartedLoading(StartedLoading event, Emitter<EntityLoaderState> emit) {
    switch (event.loadedType) {
      case List<ArtistData>:
        if (state.allArtistsWithTags.loadingStatus == LoadingStatus.initial) {
          emit(state.copyWith(allArtistsWithTags: LoadedObject.loading()));
        }
        break;
      case List<Tag>:
        if (state.allTags.loadingStatus == LoadingStatus.initial) {
          emit(state.copyWith(allTags: LoadedObject.loading()));
        }
        break;
    }
  }

  void _handleArtistsListUpdated(ArtistsListUpdated event, Emitter<EntityLoaderState> emit) {
    if (event.artistsWithTags != null) {
      emit(state.copyWith(allArtistsWithTags: LoadedObject.success(event.artistsWithTags!)));
    } else {
      emit(state.copyWith(allArtistsWithTags: LoadedObject.error()));
    }
  }

  void _handleTagsListUpdated(TagsListUpdated event, Emitter<EntityLoaderState> emit) {
    if (event.tags != null) {
      emit(state.copyWith(allTags: LoadedObject.success(event.tags!)));
    } else {
      emit(state.copyWith(allTags: LoadedObject.error()));
    }
  }
}
