import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_user_state.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loaded_object.dart';

import 'entity_loader_bloc.dart';

abstract class EntityLoaderUser<S extends EntityLoaderUserState> extends Bloc<LibraryEvent, S> {
  EntityLoaderBloc _entityLoaderBloc;

  EntityLoaderUser(S initialState, this._entityLoaderBloc) : super(initialState) {
    on<ArtistsListUpdated>(_handleArtistsListUpdated);
  }

  void _subscribeToAllArtists() {
    _entityLoaderBloc.on<ArtistsListUpdated>((event, emit) {
      this.add(event);
    });
  }

  void _handleArtistsListUpdated(ArtistsListUpdated event, Emitter<S> emit) {
    if (event.artistsWithTags != null) {
      emit(state.copyWith(allArtistsWithTags: LoadedObject.success(event.artistsWithTags!)) as S);
    } else {
      emit(state.copyWith(allArtistsWithTags: LoadedObject.error()) as S);
    }
  }
}
