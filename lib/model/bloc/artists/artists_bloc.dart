import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc/artists/artist_events.dart';
import 'package:moodtag/model/bloc/artists/artists_state.dart';
import 'package:moodtag/model/repository.dart';

class ArtistsBloc extends Bloc<ArtistEvent, ArtistsState> {
  final Repository repository;

  ArtistsBloc({this.repository}) : super(const ArtistsState()) {
    on<GetArtists>(_mapGetArtistsEventToState);
    on<SelectArtist>(_mapSelectArtistEventToState);
  }

  void _mapGetArtistsEventToState(GetArtists event, Emitter<ArtistsState> emit) async {
    emit(state.copyWith(status: ArtistsStatus.loading));
    try {
      final artists = await repository.getArtists();
      emit(
        state.copyWith(
          status: ArtistsStatus.success,
          artists: artists,
        ),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(status: ArtistsStatus.error));
    }
  }

  void _mapSelectArtistEventToState(event, Emitter<ArtistsState> emit) async {
    emit(
      state.copyWith(
        status: ArtistsStatus.selected,
        selectedArtist: event.selectedArtist,
      ),
    );
  }
}
