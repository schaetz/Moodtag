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

  void emitNewStateOnArtistsListUpdate() {
    this.on<DataUpdated<ArtistsList>>((DataUpdated<ArtistsList> event, Emitter<S> emit) {
      if (event.data != null) {
        emit(this.state.copyWith(loadedDataAllArtists: LoadedData.success(event.data)) as S);
      } else {
        emit(this.state.copyWith(loadedDataAllArtists: LoadedData.error()) as S);
      }
    });
  }

  void emitNewStateOnTagsListUpdate() {
    this.on<DataUpdated<TagsList>>((DataUpdated<TagsList> event, Emitter<S> emit) {
      if (event.data != null) {
        emit(this.state.copyWith(loadedDataAllTags: LoadedData.success(event.data)) as S);
      } else {
        emit(this.state.copyWith(loadedDataAllTags: LoadedData.error()) as S);
      }
    });
  }
}
