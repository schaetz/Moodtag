import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loaded_object.dart';

import 'entity_loader_bloc.dart';

mixin EntityLoaderUser {
  void subscribeToAllEntities(Bloc<LibraryEvent, EntityLoaderUserState> dataUserBloc, EntityLoaderBloc entityLoaderBloc,
      {bool withArtists = false, bool withTags = false}) {
    entityLoaderBloc.stream.listen((event) {
      if (event.allArtistsWithTags != dataUserBloc.state.allArtistsWithTags) {
        dataUserBloc.add(ArtistsListUpdated());
      }
      if (event.allTags != dataUserBloc.state.allTags) {
        dataUserBloc.add(TagsListUpdated());
      }
    });

    if (withArtists) {
      dataUserBloc.on<ArtistsListUpdated>((ArtistsListUpdated event, Emitter<EntityLoaderUserState> emit) {
        if (event.artistsWithTags != null) {
          emit(dataUserBloc.state.copyWith(allArtistsWithTags: LoadedObject.success(event.artistsWithTags!)));
        } else {
          emit(dataUserBloc.state.copyWith(allArtistsWithTags: LoadedObject.error()));
        }
      });
    }

    if (withTags) {
      _emitNewStateOnUpdateEvent<List<ArtistData>>(dataUserBloc);
    }
  }

  void _emitNewStateOnUpdateEvent<DataType>(
    Bloc<LibraryEvent, EntityLoaderUserState> dataUserBloc,
  ) {
    dataUserBloc.on<DataUpdated<DataType>>((DataUpdated event, Emitter<EntityLoaderUserState> emit) {
      if (event.data != null) {
        emit(dataUserBloc.state.copyWith(data: LoadedObject.success(event.data!)));
      } else {
        emit(dataUserBloc.state.copyWith(data: LoadedObject.error()));
      }
    });
  }
}
