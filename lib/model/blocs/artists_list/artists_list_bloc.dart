import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/name_already_taken_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_bloc.dart';
import 'package:moodtag/model/blocs/types.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/artist_events.dart';
import '../error_stream_handling.dart';
import 'artists_list_state.dart';

class ArtistsListBloc extends AbstractEntityUserBloc<ArtistsListState> with ErrorStreamHandling {
  late final Repository _repository;
  late StreamSubscription _filteredArtistsListStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  ArtistsListBloc(this._repository, BuildContext mainContext, EntityLoaderBloc entityLoaderBloc)
      : super(
            initialState: ArtistsListState(loadedDataAllTags: entityLoaderBloc.state.loadedDataAllTags),
            entityLoaderBloc: entityLoaderBloc,
            useAllTagsStream: true) {
    on<StartedLoading<ArtistsList>>(_handleStartedLoadingArtistsList);
    on<DataUpdated<ArtistsList>>(_handleArtistsListUpdated);
    on<ChangeArtistsListFilters>(_handleChangeArtistsListFilters);
    on<CreateArtists>(_mapCreateArtistsEventToState);
    on<DeleteArtist>(_mapDeleteArtistEventToState);
    on<ToggleTagSubtitles>(_mapToggleTagSubtitlesEventToState);
    on<ToggleFilterSelectionModal>(_mapToggleFilterOverlayEventToState);
    on<FilterSelectionModalStateChanged>(_mapFilterSelectionModalStateChangedEventToState);
    on<ActiveScreenChanged>(_mapActiveScreenChangedEventToState);

    _requestArtistsFromRepository();
    add(StartedLoading<ArtistsList>());

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _filteredArtistsListStreamSubscription.cancel();
    super.close();
  }

  void _requestArtistsFromRepository({Set<Tag> filterTags = const {}}) {
    _filteredArtistsListStreamSubscription = _repository
        .getArtistsDataList(filterTags: filterTags)
        .handleError((error) => add(DataUpdated<ArtistsList>(error: error)))
        .listen((artistsListFromStream) => add(DataUpdated<ArtistsList>(data: artistsListFromStream)));
  }

  void _handleStartedLoadingArtistsList(StartedLoading<ArtistsList> event, Emitter<ArtistsListState> emit) {
    if (state.loadedDataFilteredArtists.loadingStatus == LoadingStatus.initial) {
      emit(state.copyWith(loadedDataFilteredArtists: const LoadedData.loading()));
    }
  }

  void _handleArtistsListUpdated(DataUpdated<ArtistsList> event, Emitter<ArtistsListState> emit) {
    if (event.data != null) {
      emit(state.copyWith(loadedDataFilteredArtists: LoadedData.success(event.data)));
    } else {
      emit(state.copyWith(loadedDataFilteredArtists: const LoadedData.error()));
    }
  }

  void _handleChangeArtistsListFilters(ChangeArtistsListFilters event, Emitter<ArtistsListState> emit) async {
    if (event.filterTags != state.filterTags) {
      await _filteredArtistsListStreamSubscription.cancel();
      _requestArtistsFromRepository(filterTags: event.filterTags);
      emit(state.copyWith(filterTags: event.filterTags, loadedDataFilteredArtists: LoadedData.loading()));
    }
  }

  void _mapCreateArtistsEventToState(CreateArtists event, Emitter<ArtistsListState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateArtistsEvent(event, _repository);
    if (exception is NameAlreadyTakenException) {
      errorStreamController.add(exception);
    }
  }

  void _mapDeleteArtistEventToState(DeleteArtist event, Emitter<ArtistsListState> emit) async {
    final deleteArtistResponse = await _repository.deleteArtist(event.artist);
    if (deleteArtistResponse.didFail()) {
      errorStreamController.add(deleteArtistResponse.getUserFeedbackException());
    }
  }

  void _mapToggleTagSubtitlesEventToState(ToggleTagSubtitles event, Emitter<ArtistsListState> emit) {
    emit(state.copyWith(displayTagSubtitles: !state.displayTagSubtitles));
  }

  void _mapToggleFilterOverlayEventToState(ToggleFilterSelectionModal event, Emitter<ArtistsListState> emit) {
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

  void _mapFilterSelectionModalStateChangedEventToState(
      FilterSelectionModalStateChanged event, Emitter<ArtistsListState> emit) {
    if (state.filterSelectionModalState.isInTransition) {
      if (event.open) {
        emit(state.copyWith(
            filterSelectionModalState: ModalState.open, filterDisplayOverlayState: OverlayVisibility.off));
      } else {
        emit(state.copyWith(
            filterSelectionModalState: ModalState.closed,
            filterDisplayOverlayState: state.filterTags.isNotEmpty ? OverlayVisibility.on : OverlayVisibility.off));
      }
    }
  }

  void _mapActiveScreenChangedEventToState(ActiveScreenChanged event, Emitter<ArtistsListState> emit) {
    if (event.isActive) {
      emit(state.copyWith(
          filterDisplayOverlayState: state.filterTags.isNotEmpty ? OverlayVisibility.on : OverlayVisibility.off));
    } else if (state.filterTags.isNotEmpty) {
      emit(state.copyWith(filterDisplayOverlayState: OverlayVisibility.suspended));
    }
  }
}
