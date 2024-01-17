import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/library_subscription/config/library_query_filter.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config_factory.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/events/artist_events.dart';
import 'package:moodtag/shared/bloc/events/data_loading_events.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/bloc/extensions/error_handling/error_stream_handling.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_user_bloc_mixin.dart';
import 'package:moodtag/shared/bloc/helpers/create_entity_bloc_helper.dart';

import 'tag_details_state.dart';

class TagDetailsBloc extends Bloc<LibraryEvent, TagDetailsState> with LibraryUserBlocMixin, ErrorStreamHandling {
  final tagByIdSubscriptionName = SubscriptionConfigFactory.tagByIdSubscriptionName;
  final filteredArtistsSubscriptionName = SubscriptionConfigFactory.filteredArtistsSubscriptionName;
  final filteredArtistsWithTagSubscriptionName = SubscriptionConfigFactory.filteredArtistsWithTagSubscriptionName;

  final Repository _repository;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagDetailsBloc(this._repository, BuildContext mainContext, int tagId) : super(TagDetailsState(tagId: tagId)) {
    useLibrary(_repository);

    add(RequestOrUpdateSubscription.withConfig(SubscriptionConfigFactory.getTagByIdConfig(tagId)));
    add(RequestOrUpdateSubscription.withConfig(SubscriptionConfigFactory.getAllTagCategoriesListConfig()));
    add(RequestOrUpdateSubscription.withConfig(SubscriptionConfigFactory.getAllArtistsListConfig()));
    final artistsListFilter = LibraryQueryFilter(searchItem: state.searchItem);
    add(RequestOrUpdateSubscription.withConfig(
        SubscriptionConfigFactory.getFilteredArtistsListConfig(artistsListFilter)));

    on<ChangeCategoryForTag>(_handleChangeCategoryForTagEvent);
    on<AddArtistsForTag>(_handleAddArtistsForTagEvent);
    on<RemoveTagFromArtist>(_handleRemoveTagFromArtistEvent);
    on<ToggleSearchBar>(_handleToggleSearchBarEvent);
    on<ChangeSearchItem>(_handleChangeSearchItemEvent);
    on<ClearSearchItem>(_handleClearSearchItemEvent);
    on<ToggleChecklistMode>(_handleToggleChecklistModeEvent);
    on<ToggleTagForArtist>(_handleToggleTagForArtistEvent);

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    super.close();
    closeErrorStreamController();
  }

  @override
  TagDetailsState getNewStateForReceivedData(
      SubscriptionConfig subscriptionConfig, LoadedData loadedData, Emitter<TagDetailsState> emit) {
    if (subscriptionConfig.name == tagByIdSubscriptionName) {
      final newState =
          state.copyWith(loadedTagData: LoadedData(loadedData.data, loadingStatus: loadedData.loadingStatus));
      if (loadedData.loadingStatus.isSuccess && state.loadedDataFilteredArtistsWithTag.loadingStatus.isInitial) {
        final tagData = loadedData.data as TagData;
        add(RequestOrUpdateSubscription(ArtistsList,
            name: filteredArtistsWithTagSubscriptionName,
            filter: LibraryQueryFilter(searchItem: state.searchItem, entityFilters: {tagData.tag})));
      }
      return newState;
    } else if (subscriptionConfig.name == filteredArtistsWithTagSubscriptionName) {
      return state.copyWith(
          loadedDataFilteredArtistsWithTag: LoadedData(loadedData.data, loadingStatus: loadedData.loadingStatus));
    } else if (subscriptionConfig.name == filteredArtistsSubscriptionName) {
      return state.copyWith(
          loadedDataFilteredArtists: LoadedData(loadedData.data, loadingStatus: loadedData.loadingStatus));
    }
    return super.getNewStateForReceivedData(subscriptionConfig, loadedData, emit);
  }

  @override
  TagDetailsState getNewStateForSubscriptionError(
      SubscriptionConfig subscriptionConfig, Object? object, StackTrace? stackTrace, Emitter<TagDetailsState> emit) {
    if (subscriptionConfig.name == tagByIdSubscriptionName) {
      return state.copyWith(loadedTagData: LoadedData.error());
    } else if (subscriptionConfig.name == filteredArtistsWithTagSubscriptionName) {
      return state.copyWith(loadedDataFilteredArtistsWithTag: LoadedData.error());
    } else if (subscriptionConfig.name == filteredArtistsSubscriptionName) {
      return state.copyWith(loadedDataFilteredArtists: LoadedData.error());
    }
    return super.getNewStateForSubscriptionError(subscriptionConfig, object, stackTrace, emit);
  }

  void _handleChangeCategoryForTagEvent(ChangeCategoryForTag event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleChangeCategoryForTagEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
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

  void _handleToggleSearchBarEvent(ToggleSearchBar event, Emitter<TagDetailsState> emit) {
    final newSearchBarVisibility = !state.displaySearchBar;
    _reloadDataAfterFilterChange(
        searchItem: newSearchBarVisibility ? state.searchItem : null, displaySearchBar: newSearchBarVisibility);
    emit(state.copyWith(displaySearchBar: newSearchBarVisibility));
  }

  void _handleChangeSearchItemEvent(ChangeSearchItem event, Emitter<TagDetailsState> emit) {
    if (event.searchItem != state.searchItem) {
      _reloadDataAfterFilterChange(searchItem: event.searchItem);
      emit(state.copyWith(
          searchItem: event.searchItem,
          loadedDataFilteredArtists: LoadedData.loading(),
          loadedDataFilteredArtistsWithTag: LoadedData.loading()));
    }
  }

  void _handleClearSearchItemEvent(ClearSearchItem event, Emitter<TagDetailsState> emit) {
    if (state.searchItem != '') {
      _reloadDataAfterFilterChange(searchItem: '');
      emit(state.copyWith(
          searchItem: '',
          loadedDataFilteredArtists: LoadedData.loading(),
          loadedDataFilteredArtistsWithTag: LoadedData.loading()));
    }
  }

  void _handleToggleChecklistModeEvent(ToggleChecklistMode event, Emitter<TagDetailsState> emit) async {
    emit(state.copyWith(checklistMode: !state.checklistMode));
  }

  void _handleToggleTagForArtistEvent(ToggleTagForArtist event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleToggleTagForArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _reloadDataAfterFilterChange({bool? displaySearchBar, String? searchItem}) async {
    final applySearchItem = displaySearchBar != null ? displaySearchBar : state.displaySearchBar;
    final newSearchItem = searchItem != null ? searchItem : state.searchItem;
    final newFilterForAll = LibraryQueryFilter(searchItem: applySearchItem ? newSearchItem : '');

    // TODO Problem: If the tag has not been loaded before this method is called the first time,
    //  we cannot load the artists with tag here
    final tagData = state.loadedTagData.data as TagData;
    final newFilterWithTag =
        LibraryQueryFilter(searchItem: applySearchItem ? newSearchItem : '', entityFilters: {tagData.tag});

    add(RequestOrUpdateSubscription(ArtistsList, name: filteredArtistsSubscriptionName, filter: newFilterForAll));
    add(RequestOrUpdateSubscription(ArtistsList,
        name: filteredArtistsWithTagSubscriptionName, filter: newFilterWithTag));
  }
}
