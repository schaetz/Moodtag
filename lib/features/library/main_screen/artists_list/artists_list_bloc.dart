import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/name_already_taken_exception.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/library_query_filter.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/model/repository/subscription_config.dart';
import 'package:moodtag/shared/bloc/helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/shared/bloc/library_user/library_user_bloc_mixin.dart';
import 'package:moodtag/shared/models/modal_and_overlay_types.dart';

import '../../../../model/events/artist_events.dart';
import '../../../../shared/bloc/error_handling/error_stream_handling.dart';
import 'artists_list_state.dart';

class ArtistsListBloc extends Bloc<LibraryEvent, ArtistsListState> with LibraryUserBlocMixin, ErrorStreamHandling {
  static const filteredArtistsSubscriptionName = 'filtered_artists_list';

  late final Repository _repository;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  ArtistsListBloc(this._repository, BuildContext mainContext) : super(ArtistsListState()) {
    useLibrary(_repository);
    add(RequestOrUpdateSubscription(ArtistsList,
        name: filteredArtistsSubscriptionName,
        filter: LibraryQueryFilter(searchItem: state.searchItem, entityFilters: state.filterTags)));
    add(RequestOrUpdateSubscription(TagsList));

    on<CreateArtists>(_handleCreateArtistsEvent);
    on<DeleteArtist>(_handleDeleteArtistEvent);
    on<ToggleSearchBar>(_handleToggleSearchBarEvent);
    on<ChangeSearchItem>(_handleChangeSearchItemEvent);
    on<ClearSearchItem>(_handleClearSearchItemEvent);
    on<ToggleTagSubtitles>(_handleToggleTagSubtitlesEvent);
    on<ToggleFilterSelectionModal>(_handleToggleFilterSelectionModalEvent);
    on<FilterSelectionModalStateChanged>(_handleFilterSelectionModalStateChangedEvent);
    on<ChangeArtistsListFilters>(_handleChangeArtistsListFilters);
    on<RemoveArtistsListFilters>(_handleRemoveArtistsListFiltersEvent);

    setupErrorHandler(mainContext);
  }

  @override
  void onDataReceived(SubscriptionConfig subscriptionConfig, LoadedData loadedData, Emitter<ArtistsListState> emit) {
    super.onDataReceived(subscriptionConfig, loadedData, emit);
    if (subscriptionConfig.name == filteredArtistsSubscriptionName) {
      emit(state.copyWith(
          loadedDataFilteredArtists: LoadedData(loadedData.data, loadingStatus: loadedData.loadingStatus)));
    }
  }

  @override
  void onStreamSubscriptionError(
      SubscriptionConfig subscriptionConfig, Object object, StackTrace stackTrace, Emitter<ArtistsListState> emit) {
    super.onStreamSubscriptionError(subscriptionConfig, object, stackTrace, emit);
    if (subscriptionConfig.name == filteredArtistsSubscriptionName) {
      emit(state.copyWith(loadedDataFilteredArtists: LoadedData.error()));
    }
  }

  void _handleCreateArtistsEvent(CreateArtists event, Emitter<ArtistsListState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateArtistsEvent(event, _repository);
    if (exception is NameAlreadyTakenException) {
      errorStreamController.add(exception);
    }
  }

  void _handleDeleteArtistEvent(DeleteArtist event, Emitter<ArtistsListState> emit) async {
    final deleteArtistResponse = await _repository.deleteArtist(event.artist);
    if (deleteArtistResponse.didFail()) {
      errorStreamController.add(deleteArtistResponse.getUserFeedbackException());
    }
  }

  void _handleToggleSearchBarEvent(ToggleSearchBar event, Emitter<ArtistsListState> emit) {
    final newSearchBarVisibility = !state.displaySearchBar;
    _reloadDataAfterFilterChange(
        searchItem: newSearchBarVisibility ? state.searchItem : null, displaySearchBar: newSearchBarVisibility);
    emit(state.copyWith(displaySearchBar: newSearchBarVisibility));
  }

  void _handleChangeSearchItemEvent(ChangeSearchItem event, Emitter<ArtistsListState> emit) {
    if (event.searchItem != state.searchItem) {
      _reloadDataAfterFilterChange(searchItem: event.searchItem);
      emit(state.copyWith(searchItem: event.searchItem, loadedDataFilteredArtists: LoadedData.loading()));
    }
  }

  void _handleClearSearchItemEvent(ClearSearchItem event, Emitter<ArtistsListState> emit) {
    if (state.searchItem != '') {
      _reloadDataAfterFilterChange(searchItem: '');
      emit(state.copyWith(searchItem: '', loadedDataFilteredArtists: LoadedData.loading()));
    }
  }

  void _handleToggleTagSubtitlesEvent(ToggleTagSubtitles event, Emitter<ArtistsListState> emit) {
    emit(state.copyWith(displayTagSubtitles: !state.displayTagSubtitles));
  }

  void _handleToggleFilterSelectionModalEvent(ToggleFilterSelectionModal event, Emitter<ArtistsListState> emit) {
    if (!state.filterSelectionModalState.isInTransition) {
      if (event.wantedOpen == null) {
        if (state.filterSelectionModalState == ModalState.open) {
          emit(state.copyWith(filterSelectionModalState: ModalState.closing));
        } else if (state.filterSelectionModalState == ModalState.closed) {
          emit(state.copyWith(filterSelectionModalState: ModalState.opening));
        }
      } else if (event.wantedOpen == false && state.filterSelectionModalState == ModalState.open) {
        emit(state.copyWith(filterSelectionModalState: ModalState.closing));
      } else if (event.wantedOpen == true && state.filterSelectionModalState == ModalState.closed) {
        emit(state.copyWith(filterSelectionModalState: ModalState.opening));
      }
    }
  }

  void _handleFilterSelectionModalStateChangedEvent(
      FilterSelectionModalStateChanged event, Emitter<ArtistsListState> emit) {
    if (state.filterSelectionModalState.isInTransition) {
      if (event.open) {
        emit(state.copyWith(filterSelectionModalState: ModalState.open, displayFilterDisplayOverlay: false));
      } else {
        emit(state.copyWith(
            filterSelectionModalState: ModalState.closed, displayFilterDisplayOverlay: state.filterTags.isNotEmpty));
      }
    }
  }

  void _handleChangeArtistsListFilters(ChangeArtistsListFilters event, Emitter<ArtistsListState> emit) async {
    if (event.filterTags != state.filterTags) {
      _reloadDataAfterFilterChange(filterTags: event.filterTags);
      emit(state.copyWith(filterTags: event.filterTags, loadedDataFilteredArtists: LoadedData.loading()));
    }
  }

  void _handleRemoveArtistsListFiltersEvent(RemoveArtistsListFilters event, Emitter<ArtistsListState> emit) {
    if (state.filterTags != {}) {
      _reloadDataAfterFilterChange(filterTags: {});
    }
    emit(state.copyWith(filterTags: {}, displayFilterDisplayOverlay: false));
  }

  void _reloadDataAfterFilterChange({Set<Tag>? filterTags, bool? displaySearchBar, String? searchItem}) async {
    final applySearchItem = displaySearchBar != null ? displaySearchBar : state.displaySearchBar;
    final newSearchItem = searchItem != null ? searchItem : state.searchItem;
    final newFilter = LibraryQueryFilter(
        entityFilters: filterTags != null ? filterTags : state.filterTags,
        searchItem: applySearchItem ? newSearchItem : null);

    add(RequestOrUpdateSubscription(ArtistsList, name: filteredArtistsSubscriptionName, filter: newFilter));
  }
}
