import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';

import 'entity_loader_bloc.dart';

mixin EntityUserMixin<S extends AbstractEntityUserState> implements Bloc<LibraryEvent, S> {
  void subscribeToEntityLoader(EntityLoaderBloc entityLoaderBloc, {useArtists = false, useTags = false}) {
    entityLoaderBloc.stream.listen((entityLoaderState) {
      if (useArtists && entityLoaderState.loadedDataAllArtists != this.state.loadedDataAllArtists) {
        this.add(EntityLoaderStatusChanged<ArtistsList>(entityLoaderState.loadedDataAllArtists));
      }
      if (useTags && entityLoaderState.loadedDataAllTags != this.state.loadedDataAllTags) {
        this.add(EntityLoaderStatusChanged<TagsList>(entityLoaderState.loadedDataAllTags));
      }
    });
  }

  void onArtistsListLoadingStatusChangedEmit() {
    this.on<EntityLoaderStatusChanged<ArtistsList>>((EntityLoaderStatusChanged<ArtistsList> event, Emitter<S> emit) {
      if (event.loadedData.loadingStatus != this.state.loadedDataAllArtists?.loadingStatus) {
        emit(this.state.copyWith(loadedDataAllArtists: event.loadedData) as S);
      }
    });
  }

  void onTagsListLoadingStatusChangedEmit() {
    this.on<EntityLoaderStatusChanged<TagsList>>((EntityLoaderStatusChanged<TagsList> event, Emitter<S> emit) {
      if (event.loadedData.loadingStatus != this.state.loadedDataAllTags?.loadingStatus) {
        emit(this.state.copyWith(loadedDataAllTags: event.loadedData) as S);
      }
    });
  }
}
