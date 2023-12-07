import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/name_already_taken_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/tag_events.dart';
import '../error_stream_handling.dart';
import 'tags_list_state.dart';

class TagsListBloc extends Bloc<LibraryEvent, TagsListState> with ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _filteredTagsListStreamSubscription;
  late final StreamSubscription _allTagsStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagsListBloc(this._repository, BuildContext mainContext) : super(TagsListState()) {
    on<StartedLoading<TagsList>>(_handleStartedLoadingTagsList);
    on<DataUpdated<TagsList>>(_handleTagsListUpdated);
    on<CreateTags>(_handleCreateTagsEvent);
    on<DeleteTag>(_handleDeleteTagEvent);
    on<ToggleSearchBar>(_handleToggleSearchBarEvent);
    on<ChangeSearchItem>(_handleChangeSearchItemEvent);
    on<ClearSearchItem>(_handleClearSearchItemEvent);

    _allTagsStreamSubscription = this._repository.loadedDataAllTags.stream.listen((loadedDataValue) {
      // TODO Add an event instead
      // add(DataUpdated<TagsList>());
      emit(state.copyWith(loadedDataAllTags: loadedDataValue));
    });

    _requestTagsFromRepository();
    add(StartedLoading<TagsList>());

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _filteredTagsListStreamSubscription.cancel();
    _allTagsStreamSubscription.cancel();
    super.close();
  }

  void _requestTagsFromRepository({String? searchItem = null}) {
    _filteredTagsListStreamSubscription = _repository
        .getTagsDataList(searchItem: searchItem)
        .handleError((error) => add(DataUpdated<TagsList>(error: error)))
        .listen((tagsListFromStream) => add(DataUpdated<TagsList>(data: tagsListFromStream)));
  }

  void _handleStartedLoadingTagsList(StartedLoading<TagsList> event, Emitter<TagsListState> emit) {
    if (state.loadedDataFilteredTags.loadingStatus == LoadingStatus.initial) {
      emit(state.copyWith(loadedDataFilteredTags: const LoadedData.loading()));
    }
  }

  void _handleTagsListUpdated(DataUpdated<TagsList> event, Emitter<TagsListState> emit) {
    if (event.data != null) {
      emit(state.copyWith(loadedDataFilteredTags: LoadedData.success(event.data)));
    } else {
      emit(state.copyWith(loadedDataFilteredTags: const LoadedData.error('List of tags could not be loaded')));
    }
  }

  void _handleCreateTagsEvent(CreateTags event, Emitter<TagsListState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    if (exception is NameAlreadyTakenException) {
      errorStreamController.add(exception);
    }
  }

  void _handleDeleteTagEvent(DeleteTag event, Emitter<TagsListState> emit) async {
    final deleteTagResponse = await _repository.deleteTag(event.tag);
    if (deleteTagResponse.didFail()) {
      errorStreamController.add(deleteTagResponse.getUserFeedbackException());
    }
  }

  void _handleToggleSearchBarEvent(ToggleSearchBar event, Emitter<TagsListState> emit) {
    final newSearchBarVisibility = !state.displaySearchBar;
    _reloadDataAfterFilterChange(searchItem: newSearchBarVisibility ? state.searchItem : null);
    emit(state.copyWith(displaySearchBar: newSearchBarVisibility));
  }

  void _handleChangeSearchItemEvent(ChangeSearchItem event, Emitter<TagsListState> emit) {
    if (event.searchItem != state.searchItem) {
      _reloadDataAfterFilterChange(searchItem: event.searchItem);
      emit(state.copyWith(searchItem: event.searchItem, loadedDataFilteredTags: LoadedData.loading()));
    }
  }

  void _handleClearSearchItemEvent(ClearSearchItem event, Emitter<TagsListState> emit) {
    if (state.searchItem != '') {
      _reloadDataAfterFilterChange(searchItem: '');
      emit(state.copyWith(searchItem: '', loadedDataFilteredTags: LoadedData.loading()));
    }
  }

  void _reloadDataAfterFilterChange({String? searchItem}) async {
    await _filteredTagsListStreamSubscription.cancel();
    _requestTagsFromRepository(searchItem: searchItem);
  }
}
