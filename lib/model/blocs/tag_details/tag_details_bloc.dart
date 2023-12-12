import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/library_user/library_user_bloc_mixin.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'tag_details_state.dart';

class TagDetailsBloc extends Bloc<LibraryEvent, TagDetailsState> with LibraryUserBlocMixin, ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _tagStreamSubscription;
  StreamSubscription? _artistsWithThisTagOnlyStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagDetailsBloc(this._repository, BuildContext mainContext, int tagId) : super(TagDetailsState(tagId: tagId)) {
    useLibrary(_repository);
    on<StartedLoading<TagData>>(_handleStartedLoadingTagData);
    on<DataUpdated<TagData>>(_handleTagDataUpdated);
    on<StartedLoading<ArtistsList>>(_handleStartedLoadingArtistsWithThisTagOnly);
    on<DataUpdated<ArtistsList>>(_handleArtistsWithThisTagOnlyDataUpdated);
    on<AddArtistsForTag>(_handleAddArtistsForTagEvent);
    on<RemoveTagFromArtist>(_handleRemoveTagFromArtistEvent);
    on<ToggleArtistsForTagChecklist>(_handleToggleArtistsForTagChecklistEvent);
    on<ToggleTagForArtist>(_handleToggleTagForArtistEvent);

    add(RequestSubscription<ArtistsList>());

    _tagStreamSubscription = _repository
        .getTagDataById(tagId)
        .handleError((error) => add(DataUpdated<TagData>(error: error)))
        .listen((tagFromStream) => add(DataUpdated<TagData>(data: tagFromStream)));
    add(StartedLoading<TagData>());

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _tagStreamSubscription.cancel();
    _artistsWithThisTagOnlyStreamSubscription?.cancel();
    super.close();
  }

  void _handleStartedLoadingTagData(StartedLoading<TagData> event, Emitter<TagDetailsState> emit) {
    if (state.loadedTagData.loadingStatus == LoadingStatus.initial) {
      emit(state.copyWith(loadedTagData: LoadedData.loading()));
    }
  }

  void _handleTagDataUpdated(DataUpdated<TagData> event, Emitter<TagDetailsState> emit) {
    if (event.data != null) {
      emit(state.copyWith(loadedTagData: LoadedData.success(event.data)));
      if (_artistsWithThisTagOnlyStreamSubscription == null && event.data?.tag != null) {
        _requestArtistsWithThisTagOnlyFromRepository(event.data!.tag);
        add(StartedLoading<ArtistsList>());
      }
    } else {
      emit(state.copyWith(loadedTagData: LoadedData.error(message: 'Tag data could not be loaded')));
    }
  }

  void _requestArtistsWithThisTagOnlyFromRepository(Tag tag) {
    _artistsWithThisTagOnlyStreamSubscription = _repository
        .getArtistsDataList(filterTags: Set.of([tag]))
        .handleError((error) => add(DataUpdated<ArtistsList>(error: error)))
        .listen((artistsListFromStream) => add(DataUpdated<ArtistsList>(data: artistsListFromStream)));
  }

  void _handleStartedLoadingArtistsWithThisTagOnly(StartedLoading<ArtistsList> event, Emitter<TagDetailsState> emit) {
    if (state.artistsWithThisTagOnly.loadingStatus == LoadingStatus.initial) {
      emit(state.copyWith(artistsWithThisTagOnly: LoadedData.loading()));
    }
  }

  void _handleArtistsWithThisTagOnlyDataUpdated(DataUpdated<ArtistsList> event, Emitter<TagDetailsState> emit) {
    if (event.data != null) {
      emit(state.copyWith(artistsWithThisTagOnly: LoadedData.success(event.data)));
    } else {
      emit(state.copyWith(
          artistsWithThisTagOnly: LoadedData.error(message: 'Artists with this tag could not be loaded')));
    }
  }

  void _handleAddArtistsForTagEvent(AddArtistsForTag event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleAddArtistsForTagEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _handleRemoveTagFromArtistEvent(RemoveTagFromArtist event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleRemoveTagFromArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _handleToggleArtistsForTagChecklistEvent(
      ToggleArtistsForTagChecklist event, Emitter<TagDetailsState> emit) async {
    emit(state.copyWith(checklistMode: !state.checklistMode));
  }

  void _handleToggleTagForArtistEvent(ToggleTagForArtist event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleToggleTagForArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }
}
