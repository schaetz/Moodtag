import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/repository.dart';

import 'artist_details_state.dart';

class ArtistDetailsCubit extends Cubit<ArtistDetailsState> {
  final Repository repository;

  ArtistDetailsCubit({this.repository, int artistId}) : super(ArtistDetailsState(artistId: artistId));

  void initialize() async {
    emit(state.copyWith(artistLoadingStatus: LoadingStatus.loading));
    try {
      final artist = await repository.getArtistById(state.artistId);
      emit(
        state.copyWith(artistLoadingStatus: LoadingStatus.success, artist: artist),
      );
      await _loadTagsForArtist();
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(artistLoadingStatus: LoadingStatus.error));
    }

    emit(state.copyWith(tagsListLoadingStatus: LoadingStatus.loading));
  }

  void _loadTagsForArtist() async {
    emit(
      state.copyWith(tagsListLoadingStatus: LoadingStatus.loading),
    );
    try {
      final tagsForArtist = await repository.getArtists();
      emit(
        state.copyWith(tagsListLoadingStatus: LoadingStatus.success, tagsForArtist: tagsForArtist),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(tagsListLoadingStatus: LoadingStatus.error));
    }
  }

  void toggleTagEditMode() {
    emit(state.copyWith(tagEditMode: !state.tagEditMode));
  }
}
