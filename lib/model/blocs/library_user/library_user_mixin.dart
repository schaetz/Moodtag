import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'library_user_state_interface.dart';

mixin LibraryUserMixin<S extends ILibraryUserState> on Bloc<LibraryEvent, S> {
  StreamSubscription? _allArtistsStreamSubscription;
  StreamSubscription? _allTagsStreamSubscription;

  void useLibrary(Repository repository, {bool doUseAllArtists = true, bool doUseAllTags = true}) {
    if (doUseAllArtists) useAllArtists(repository);
    if (doUseAllTags) useAllTags(repository);
  }

  void useAllArtists(Repository repository) {
    on<AllArtistsUpdated>(_handleArtistsListUpdated);
    _allArtistsStreamSubscription = repository.loadedDataAllArtists.stream.listen((loadedDataValue) {
      add(AllArtistsUpdated(data: loadedDataValue));
    });
  }

  void useAllTags(Repository repository) {
    on<AllTagsUpdated>(_handleTagsListUpdated);
    _allTagsStreamSubscription = repository.loadedDataAllTags.stream.listen((loadedDataValue) {
      add(AllTagsUpdated(data: loadedDataValue));
    });
  }

  void closeLibraryStreams() {
    _allArtistsStreamSubscription?.cancel();
    _allTagsStreamSubscription?.cancel();
  }

  void _handleArtistsListUpdated(AllArtistsUpdated event, Emitter<S> emit) {
    if (this.state.allArtistsData == null) return;

    if (_hasLoadingStatusChanged(event, this.state.allArtistsData!) ||
        _hasDataChangedAfterLoadingFinished(event, this.state.allArtistsData!)) {
      emit(this.state.copyWith(loadedDataAllArtists: event.data) as S);
    }
  }

  void _handleTagsListUpdated(AllTagsUpdated event, Emitter<S> emit) {
    if (this.state.allTagsData == null) return;

    if (_hasLoadingStatusChanged(event, this.state.allTagsData!) ||
        _hasDataChangedAfterLoadingFinished(event, this.state.allTagsData!)) {
      emit(this.state.copyWith(loadedDataAllTags: event.data) as S);
    }
  }

  bool _hasLoadingStatusChanged(DataUpdated event, LoadedData<List<dynamic>> currentStateData) =>
      event.data.loadingStatus != currentStateData.loadingStatus;

  bool _hasDataChangedAfterLoadingFinished(DataUpdated event, LoadedData<List<dynamic>> currentStateData) =>
      event.data.loadingStatus == LoadingStatus.success && (event.data != currentStateData || event.data == null);
}
