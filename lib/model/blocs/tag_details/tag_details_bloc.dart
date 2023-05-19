import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'tag_details_state.dart';

class TagDetailsBloc extends Bloc<LibraryEvent, TagDetailsState> with ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _tagStreamSubscription;
  late final StreamSubscription _artistsWithTagFlagStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagDetailsBloc(this._repository, BuildContext mainContext, int tagId)
      : super(TagDetailsState(tagId: tagId, checklistMode: false)) {
    on<TagUpdated>(_mapTagUpdatedEventToState);
    on<ArtistsListPlusUpdated>(_mapArtistsListPlusUpdatedEventToState);
    on<AddArtistsForTag>(_mapAddArtistsForTagEventToState);
    on<RemoveTagFromArtist>(_mapRemoveTagFromArtistEventToState);
    on<ToggleArtistsForTagChecklist>(_mapToggleArtistsForTagChecklistEventToState);
    on<ToggleTagForArtist>(_mapToggleTagForArtistEventToState);

    _tagStreamSubscription = _repository
        .getTagById(tagId)
        .handleError((error) => add(TagUpdated(error: error)))
        .listen((tagFromStream) => add(TagUpdated(tag: tagFromStream)));
    _artistsWithTagFlagStreamSubscription = _repository
        .getArtistsWithTagFlag(tagId)
        .handleError((error) => add(ArtistsListPlusUpdated(error: error)))
        .listen((artistsListFromStream) => add(ArtistsListPlusUpdated(artistWithTagFlag: artistsListFromStream)));

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _tagStreamSubscription.cancel();
    _artistsWithTagFlagStreamSubscription.cancel();
    super.close();
  }

  void _mapTagUpdatedEventToState(TagUpdated event, Emitter<TagDetailsState> emit) {
    if (event.tag != null) {
      emit(state.copyWith(tag: event.tag, tagLoadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(tagLoadingStatus: LoadingStatus.error));
    }
  }

  void _mapArtistsListPlusUpdatedEventToState(ArtistsListPlusUpdated event, Emitter<TagDetailsState> emit) {
    if (event.artistWithTagFlag != null) {
      emit(
          state.copyWith(artistsWithTagFlag: event.artistWithTagFlag, artistsListLoadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(artistsListLoadingStatus: LoadingStatus.error));
    }
  }

  void _mapAddArtistsForTagEventToState(AddArtistsForTag event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleAddArtistsForTagEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _mapRemoveTagFromArtistEventToState(RemoveTagFromArtist event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleRemoveTagFromArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _mapToggleArtistsForTagChecklistEventToState(
      ToggleArtistsForTagChecklist event, Emitter<TagDetailsState> emit) async {
    emit(state.copyWith(checklistMode: !state.checklistMode));
  }

  void _mapToggleTagForArtistEventToState(ToggleTagForArtist event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleToggleTagForArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }
}
