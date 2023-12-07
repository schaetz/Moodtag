import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/ILibraryUserState.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';

mixin LibraryUserMixin<S extends ILibraryUserState> on Bloc<LibraryEvent, S> {
  void handleLibraryUpdates() {
    // TODO Resolve interference between different streams of the same type in one bloc
    on<DataUpdated<LoadedData<ArtistsList>>>(_handleArtistsListUpdated);
    on<DataUpdated<LoadedData<TagsList>>>(_handleTagsListUpdated);
  }

  void _handleArtistsListUpdated(DataUpdated<LoadedData<ArtistsList>> event, Emitter<S> emit) {
    if (this.state.allArtistsData == null) return;

    if (_hasLoadingStatusChanged(event, this.state.allArtistsData!) ||
        _hasDataChangedAfterLoadingFinished(event, this.state.allArtistsData!)) {
      emit(this.state.copyWith(loadedDataAllArtists: event.data) as S);
    }
  }

  void _handleTagsListUpdated(DataUpdated<LoadedData<TagsList>> event, Emitter<S> emit) {
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
