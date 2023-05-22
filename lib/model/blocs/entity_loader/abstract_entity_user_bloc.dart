import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';

import 'entity_loader_bloc.dart';

abstract class AbstractEntityUserBloc<S extends AbstractEntityUserState> extends Bloc<LibraryEvent, S> {
  late final StreamSubscription _allEntitiesStreamSubscription;

  AbstractEntityUserBloc(
      {required S initialState,
      required EntityLoaderBloc entityLoaderBloc,
      useAllArtistsStream = false,
      useAllTagsStream = false})
      : super(initialState) {
    if (useAllArtistsStream) {
      _onArtistsListLoadingStatusChangedEmit();
    }
    if (useAllTagsStream) {
      _onTagsListLoadingStatusChangedEmit();
    }

    _allEntitiesStreamSubscription = entityLoaderBloc.stream.listen((entityLoaderState) {
      if (useAllArtistsStream && entityLoaderState.loadedDataAllArtists != this.state.loadedDataAllArtists) {
        this.add(EntityLoaderStatusChanged<ArtistsList>(entityLoaderState.loadedDataAllArtists));
      }
      if (useAllTagsStream && entityLoaderState.loadedDataAllTags != this.state.loadedDataAllTags) {
        this.add(EntityLoaderStatusChanged<TagsList>(entityLoaderState.loadedDataAllTags));
      }
    });
  }

  @override
  Future<void> close() async {
    _allEntitiesStreamSubscription.cancel();
    super.close();
  }

  void _onArtistsListLoadingStatusChangedEmit() {
    this.on<EntityLoaderStatusChanged<ArtistsList>>((EntityLoaderStatusChanged<ArtistsList> event, Emitter<S> emit) {
      if (_hasLoadingStatusChanged(event) ||
          _hasDataChangedAfterLoadingFinished(event, this.state.loadedDataAllArtists)) {
        emit(this.state.copyWith(loadedDataAllArtists: event.loadedData) as S);
      }
    });
  }

  void _onTagsListLoadingStatusChangedEmit() {
    this.on<EntityLoaderStatusChanged<TagsList>>((EntityLoaderStatusChanged<TagsList> event, Emitter<S> emit) {
      if (_hasLoadingStatusChanged(event) || _hasDataChangedAfterLoadingFinished(event, this.state.loadedDataAllTags)) {
        emit(this.state.copyWith(loadedDataAllTags: event.loadedData) as S);
      }
    });
  }

  bool _hasLoadingStatusChanged(EntityLoaderStatusChanged event) =>
      event.loadedData.loadingStatus != this.state.loadedDataAllTags?.loadingStatus;

  bool _hasDataChangedAfterLoadingFinished(EntityLoaderStatusChanged event, dynamic currentStateData) =>
      event.loadedData.loadingStatus == LoadingStatus.success && event.loadedData.data != currentStateData;
}
