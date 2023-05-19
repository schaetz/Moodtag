import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_user_mixin.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'artist_details_state.dart';

class ArtistDetailsBloc extends Bloc<LibraryEvent, ArtistDetailsState>
    with EntityUserMixin<ArtistDetailsState>, ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _artistStreamSubscription;
  late final StreamSubscription _tagsForArtistStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();
  StreamController<UserReadableException> errorStreamController = StreamController<UserReadableException>();

  ArtistDetailsBloc(this._repository, BuildContext mainContext, int artistId, EntityLoaderBloc entityLoaderBloc)
      : super(ArtistDetailsState(
            artistId: artistId, tagEditMode: false, loadedDataAllTags: entityLoaderBloc.state.loadedDataAllTags)) {
    subscribeToEntityLoader(entityLoaderBloc);
    emitNewStateOnTagsListUpdate();

    on<ArtistUpdated>(_mapArtistUpdatedEventToState);
    on<TagsForArtistListUpdated>(_mapTagsForArtistListUpdatedEventToState);
    on<ToggleTagEditMode>(_mapToggleTagEditModeEventToState);
    on<CreateTags>(_mapCreateTagsEventToState);
    on<ToggleTagForArtist>(_mapToggleTagForArtistEventToState);

    _artistStreamSubscription = _repository
        .getArtistById(artistId)
        .handleError((error) => add(ArtistUpdated(error: error)))
        .listen((artistFromStream) => add(ArtistUpdated(artist: artistFromStream)));
    _tagsForArtistStreamSubscription = _repository
        .getTagsForArtist(artistId)
        .handleError((error) => add(TagsForArtistListUpdated(error: error)))
        .listen((tagsListFromStream) => add(TagsForArtistListUpdated(tags: tagsListFromStream)));

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _artistStreamSubscription.cancel();
    _tagsForArtistStreamSubscription.cancel();
    super.close();
  }

  void _mapArtistUpdatedEventToState(ArtistUpdated event, Emitter<ArtistDetailsState> emit) {
    if (event.artist != null) {
      emit(state.copyWith(artist: event.artist, artistLoadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(artistLoadingStatus: LoadingStatus.error));
    }
  }

  void _mapTagsForArtistListUpdatedEventToState(TagsForArtistListUpdated event, Emitter<ArtistDetailsState> emit) {
    if (event.tags != null) {
      emit(state.copyWith(tagsForArtist: event.tags, tagsForArtistLoadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(tagsForArtistLoadingStatus: LoadingStatus.error));
    }
  }

  void _mapToggleTagEditModeEventToState(ToggleTagEditMode event, Emitter<ArtistDetailsState> emit) {
    emit(state.copyWith(tagEditMode: !state.tagEditMode));
  }

  void _mapCreateTagsEventToState(CreateTags event, Emitter<ArtistDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    if (exception is NameAlreadyTakenException) {
      errorStreamController.add(exception);
    }
  }

  void _mapToggleTagForArtistEventToState(ToggleTagForArtist event, Emitter<ArtistDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleToggleTagForArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }
}
