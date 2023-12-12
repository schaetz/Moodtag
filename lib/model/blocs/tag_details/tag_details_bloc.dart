import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/library_user/library_user_bloc_mixin.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
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
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagDetailsBloc(this._repository, BuildContext mainContext, int tagId) : super(TagDetailsState(tagId: tagId)) {
    useLibrary(_repository);
    on<StartedLoading<TagData>>(_handleStartedLoadingTagData);
    on<DataUpdated<TagData>>(_handleTagDataUpdated);
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
    } else {
      emit(state.copyWith(loadedTagData: LoadedData.error(message: 'Tag data could not be loaded')));
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
