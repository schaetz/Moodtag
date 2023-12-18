import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/name_already_taken_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/library_user/library_user_bloc_mixin.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/library_query_filter.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/model/repository/subscription_config.dart';

import '../../events/tag_events.dart';
import '../error_stream_handling.dart';
import 'tags_list_state.dart';

class TagsListBloc extends Bloc<LibraryEvent, TagsListState> with LibraryUserBlocMixin, ErrorStreamHandling {
  static const filteredTagsSubscriptionName = 'filtered_tags_list';

  final Repository _repository;

  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagsListBloc(this._repository, BuildContext mainContext) : super(TagsListState()) {
    useLibrary(_repository);

    add(RequestOrUpdateSubscription(TagsList));
    add(RequestOrUpdateSubscription(TagsList,
        name: filteredTagsSubscriptionName, filter: LibraryQueryFilter(searchItem: state.searchItem)));

    on<CreateTags>(_handleCreateTagsEvent);
    on<DeleteTag>(_handleDeleteTagEvent);
    on<ToggleSearchBar>(_handleToggleSearchBarEvent);
    on<ChangeSearchItem>(_handleChangeSearchItemEvent);
    on<ClearSearchItem>(_handleClearSearchItemEvent);

    setupErrorHandler(mainContext);
  }

  @override
  void onDataReceived(SubscriptionConfig subscriptionConfig, LoadedData loadedData, Emitter<TagsListState> emit) {
    super.onDataReceived(subscriptionConfig, loadedData, emit);
    if (subscriptionConfig.name == filteredTagsSubscriptionName) {
      emit(
          state.copyWith(loadedDataFilteredTags: LoadedData(loadedData.data, loadingStatus: loadedData.loadingStatus)));
    }
  }

  @override
  void onStreamSubscriptionError(
      SubscriptionConfig subscriptionConfig, Object object, StackTrace stackTrace, Emitter<TagsListState> emit) {
    super.onStreamSubscriptionError(subscriptionConfig, object, stackTrace, emit);
    if (subscriptionConfig.name == filteredTagsSubscriptionName) {
      emit(state.copyWith(loadedDataFilteredTags: LoadedData.error()));
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
    _reloadDataAfterFilterChange(
        searchItem: newSearchBarVisibility ? state.searchItem : null, displaySearchBar: newSearchBarVisibility);
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

  void _reloadDataAfterFilterChange({bool? displaySearchBar, String? searchItem}) async {
    final applySearchItem = displaySearchBar != null ? displaySearchBar : state.displaySearchBar;
    final newSearchItem = searchItem != null ? searchItem : state.searchItem;
    final newFilter = LibraryQueryFilter(searchItem: applySearchItem ? newSearchItem : null);

    add(RequestOrUpdateSubscription(TagsList, name: filteredTagsSubscriptionName, filter: newFilter));
  }
}
