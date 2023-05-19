import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loaded_object.dart';

import 'entity_loader_bloc.dart';

mixin EntityUserMixin<S extends AbstractEntityUserState> implements Bloc<LibraryEvent, S> {
  void subscribeToEntityLoader(EntityLoaderBloc entityLoaderBloc) {
    entityLoaderBloc.stream.listen((event) {
      if (event.loadedDataAllArtists != this.state.loadedDataAllArtists) {
        this.add(DataUpdated<ArtistsList>());
      }
      if (event.loadedDataAllTags != this.state.loadedDataAllTags) {
        this.add(DataUpdated<TagsList>());
      }
    });
  }

  void onArtistsListUpdateEmit() {
    this.on<StartedLoading<ArtistsList>>(
        (StartedLoading<ArtistsList> event, Emitter<S> emit) => _handleStartedLoadingArtistsList(event, emit));
    this.on<DataUpdated<ArtistsList>>(
        (DataUpdated<ArtistsList> event, Emitter<S> emit) => _handleArtistsListUpdate(event, emit));
  }

  void onTagsListUpdateEmit() {
    this.on<StartedLoading<TagsList>>(
        (StartedLoading<TagsList> event, Emitter<S> emit) => _handleStartedLoadingTagsList(event, emit));
    this.on<DataUpdated<TagsList>>(
        (DataUpdated<TagsList> event, Emitter<S> emit) => _handleTagsListUpdate(event, emit));
  }

  void _handleStartedLoadingArtistsList(StartedLoading<ArtistsList> event, Emitter<S> emit) {
    if (this.state.loadedDataAllArtists?.loadingStatus == LoadedData.initial()) {
      emit(this.state.copyWith(loadedDataAllArtists: LoadedData.loading()) as S);
    }
  }

  void _handleStartedLoadingTagsList(StartedLoading<TagsList> event, Emitter<S> emit) {
    if (this.state.loadedDataAllTags?.loadingStatus == LoadedData.initial()) {
      emit(this.state.copyWith(loadedDataAllTags: LoadedData.loading()) as S);
    }
  }

  void _handleArtistsListUpdate(DataUpdated<ArtistsList> event, Emitter<S> emit) {
    if (event.data != null) {
      emit(this.state.copyWith(loadedDataAllArtists: LoadedData.success(event.data)) as S);
    } else {
      emit(this.state.copyWith(loadedDataAllArtists: LoadedData.error()) as S);
    }
  }

  void _handleTagsListUpdate(DataUpdated<TagsList> event, Emitter<S> emit) {
    if (event.data != null) {
      emit(this.state.copyWith(loadedDataAllTags: LoadedData.success(event.data)) as S);
    } else {
      emit(this.state.copyWith(loadedDataAllTags: LoadedData.error()) as S);
    }
  }
}
