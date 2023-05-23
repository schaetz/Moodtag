import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_bloc.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'tag_details_state.dart';

class TagDetailsBloc extends AbstractEntityUserBloc<TagDetailsState> with ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _tagStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagDetailsBloc(this._repository, BuildContext mainContext, int tagId, EntityLoaderBloc entityLoaderBloc)
      : super(
            initialState: TagDetailsState(
                tagId: tagId, checklistMode: false, loadedDataAllArtists: entityLoaderBloc.state.loadedDataAllArtists),
            entityLoaderBloc: entityLoaderBloc,
            useAllArtistsStream: true) {
    on<StartedLoading<TagData>>(_handleStartedLoadingTagData);
    on<DataUpdated<TagData>>(_handleTagDataUpdated);
    on<AddArtistsForTag>(_mapAddArtistsForTagEventToState);
    on<RemoveTagFromArtist>(_mapRemoveTagFromArtistEventToState);
    on<ToggleArtistsForTagChecklist>(_mapToggleArtistsForTagChecklistEventToState);
    on<ToggleTagForArtist>(_mapToggleTagForArtistEventToState);

    _tagStreamSubscription = _repository
        .getTagWithArtistFreqById(tagId)
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
      emit(state.copyWith(loadedTagData: LoadedData.error()));
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
