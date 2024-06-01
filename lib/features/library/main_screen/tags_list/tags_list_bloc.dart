import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/library_subscription/config/library_query_filter.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config_factory.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/events/data_loading_events.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_user_bloc_mixin.dart';
import 'package:moodtag/shared/bloc/helpers/create_entity_bloc_helper.dart';

import '../../../../shared/bloc/events/tag_events.dart';
import '../../../../shared/bloc/extensions/error_handling/error_stream_handling.dart';
import 'tags_list_state.dart';

class TagsListBloc extends Bloc<LibraryEvent, TagsListState> with LibraryUserBlocMixin, ErrorStreamHandling {
  final filteredTagsSubscriptionName = SubscriptionConfigFactory.filteredTagsSubscriptionName;

  final Repository _repository;

  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagsListBloc(this._repository, BuildContext mainContext) : super(TagsListState()) {
    useLibrary(_repository);

    final tagsListFilter = LibraryQueryFilter(searchItem: state.searchItem);
    add(RequestOrUpdateSubscription.withConfig(SubscriptionConfigFactory.getFilteredTagsListConfig(tagsListFilter)));
    add(RequestOrUpdateSubscription.withConfig(SubscriptionConfigFactory.getAllTagsListConfig()));

    on<CreateTags>(_handleCreateTagsEvent);
    on<DeleteTag>(_handleDeleteTagEvent);
    on<ToggleSearchBar>(_handleToggleSearchBarEvent);
    on<ChangeSearchItem>(_handleChangeSearchItemEvent);
    on<ClearSearchItem>(_handleClearSearchItemEvent);

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    super.close();
    closeErrorStreamController();
  }

  @override
  TagsListState getNewStateForReceivedData(
      SubscriptionConfig subscriptionConfig, LoadedData loadedData, Emitter<TagsListState> emit) {
    if (subscriptionConfig.name == filteredTagsSubscriptionName) {
      return state.copyWith(
          loadedDataFilteredTags: LoadedData(loadedData.data, loadingStatus: loadedData.loadingStatus));
    }
    return super.getNewStateForReceivedData(subscriptionConfig, loadedData, emit);
  }

  @override
  TagsListState getNewStateForSubscriptionError(
      SubscriptionConfig subscriptionConfig, Object? object, StackTrace? stackTrace, Emitter<TagsListState> emit) {
    if (subscriptionConfig.name == filteredTagsSubscriptionName) {
      final errorMessage = object is String ? object : (object is SqliteException ? object.message : null);
      log.warning("Stream subscription error in TagsListBloc: $errorMessage", object);
      return state.copyWith(loadedDataFilteredTags: LoadedData.error(message: errorMessage));
    }
    return super.getNewStateForSubscriptionError(subscriptionConfig, object, stackTrace, emit);
  }

  void _handleCreateTagsEvent(CreateTags event, Emitter<TagsListState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    if (exception != null) {
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
    final newFilter = LibraryQueryFilter(searchItem: applySearchItem ? newSearchItem : '');

    add(RequestOrUpdateSubscription(List<Tag>, name: filteredTagsSubscriptionName, filter: newFilter));
  }
}
