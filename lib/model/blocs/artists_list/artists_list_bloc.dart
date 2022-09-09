import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/repository.dart';

import '../../events/artist_events.dart';
import '../loading_status.dart';
import 'artists_list_state.dart';

class ArtistsListBloc extends Bloc<ArtistEvent, ArtistsListState> {
  final Repository repository;

  ArtistsListBloc({this.repository}) : super(const ArtistsListState()) {
    on<GetArtists>(_mapGetArtistsEventToState);
  }

  void _mapGetArtistsEventToState(GetArtists event, Emitter<ArtistsListState> emit) async {
    emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    try {
      final artists = await repository.getArtists();
      emit(
        state.copyWith(
          loadingStatus: LoadingStatus.success,
          artists: artists,
        ),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(loadingStatus: LoadingStatus.error));
    }
  }
}
