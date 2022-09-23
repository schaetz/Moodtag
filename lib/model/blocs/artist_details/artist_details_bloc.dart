import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_artist_bloc_helper.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'artist_details_state.dart';

class ArtistDetailsBloc extends Bloc<ArtistEvent, ArtistDetailsState> {
  final Repository repository;
  final CreateArtistBlocHelper createArtistBlocHelper = CreateArtistBlocHelper();

  ArtistDetailsBloc({this.repository}) : super(ArtistDetailsState()) {
    on<GetSelectedArtist>(_mapGetSelectedArtistEventToState);
    on<ToggleTagEditMode>(_mapToggleTagEditModeEventToState);
    on<CreateArtists>(_mapCreateArtistsEventToState);
  }

  void _mapGetSelectedArtistEventToState(GetSelectedArtist event, Emitter<ArtistDetailsState> emit) async {
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
  }

  void _loadTagsForArtist() async {
    emit(
      state.copyWith(tagsListLoadingStatus: LoadingStatus.loading),
    );
    try {
      final tagsForArtist = await repository.getTagsForArtist(state.artistId);
      emit(
        state.copyWith(tagsListLoadingStatus: LoadingStatus.success, tagsForArtist: tagsForArtist),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(tagsListLoadingStatus: LoadingStatus.error));
    }
  }

  void _mapToggleTagEditModeEventToState(ToggleTagEditMode event, Emitter<ArtistDetailsState> emit) {
    emit(state.copyWith(tagEditMode: !state.tagEditMode));
  }

  void _mapCreateArtistsEventToState(CreateArtists event, Emitter<ArtistDetailsState> emit) async {
    await createArtistBlocHelper.handleCreateArtistEvent(event, repository);
  }
}
