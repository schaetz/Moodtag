import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/repository/loaded_object.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';

class EntityLoaderBloc extends Bloc<DataLoadingEvent, EntityLoaderState> {
  late final Repository _repository;
  late StreamSubscription _artistsStreamSubscription;
  late StreamSubscription _tagsStreamSubscription;

  EntityLoaderBloc(BuildContext mainContext) : super(EntityLoaderState.initial()) {
    this._repository = mainContext.read<Repository>();

    on<StartedLoading>(_handleStartedLoading);
    on<DataUpdated<ArtistsList>>(_handleArtistsListUpdated);
    on<DataUpdated<TagsList>>(_handleTagsListUpdated);

    _artistsStreamSubscription = _repository
        .getArtistsWithTags()
        .handleError((error) => add(DataUpdated<ArtistsList>(error: error)))
        .listen((artistsListFromStream) => add(DataUpdated<ArtistsList>(data: artistsListFromStream)));
    add(StartedLoading<ArtistsList>());

    _tagsStreamSubscription = _repository
        .getTagsWithArtistFreq()
        .handleError((error) => add(DataUpdated<TagsList>(error: error)))
        .listen((tagsListFromStream) => add(DataUpdated<TagsList>(data: tagsListFromStream)));
    add(StartedLoading<TagsList>());
  }

  @override
  Future<void> close() async {
    _artistsStreamSubscription.cancel();
    _tagsStreamSubscription.cancel();
    super.close();
  }

  void _handleStartedLoading(StartedLoading event, Emitter<EntityLoaderState> emit) {
    if (event is StartedLoading<ArtistsList>) {
      if (state.loadedDataAllArtists.loadingStatus == LoadingStatus.initial) {
        emit(state.copyWith(allArtistsWithTags: LoadedData.loading()));
      }
    } else if (event is StartedLoading<TagsList>) {
      if (state.loadedDataAllTags.loadingStatus == LoadingStatus.initial) {
        emit(state.copyWith(allTags: LoadedData.loading()));
      }
    }
  }

  void _handleArtistsListUpdated(DataUpdated<ArtistsList> event, Emitter<EntityLoaderState> emit) {
    if (event.data != null) {
      emit(state.copyWith(allArtistsWithTags: LoadedData.success(event.data)));
    } else {
      emit(state.copyWith(allArtistsWithTags: LoadedData.error()));
    }
  }

  void _handleTagsListUpdated(DataUpdated<TagsList> event, Emitter<EntityLoaderState> emit) {
    if (event.data != null) {
      emit(state.copyWith(allTags: LoadedData.success(event.data)));
    } else {
      emit(state.copyWith(allTags: LoadedData.error()));
    }
  }
}
