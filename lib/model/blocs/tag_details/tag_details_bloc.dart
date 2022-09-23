import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'tag_details_state.dart';

class TagDetailsBloc extends Bloc<TagEvent, TagDetailsState> {
  final Repository repository;

  TagDetailsBloc({this.repository}) : super(TagDetailsState()) {
    on<GetSelectedTag>(_mapGetSelectedTagEventToState);
  }

  void _mapGetSelectedTagEventToState(GetSelectedTag event, Emitter<TagDetailsState> emit) async {
    emit(state.copyWith(tagLoadingStatus: LoadingStatus.loading));
    try {
      final tag = await repository.getTagById(state.tagId);
      emit(
        state.copyWith(tagLoadingStatus: LoadingStatus.success, tag: tag),
      );
      await _loadArtistsWithTag();
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(tagLoadingStatus: LoadingStatus.error));
    }
  }

  void _loadArtistsWithTag() async {
    emit(
      state.copyWith(artistsListLoadingStatus: LoadingStatus.loading),
    );
    try {
      final artistsWithTag = await repository.getArtistsWithTag(state.tagId);
      emit(
        state.copyWith(artistsListLoadingStatus: LoadingStatus.success, artistsWithTag: artistsWithTag),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(artistsListLoadingStatus: LoadingStatus.error));
    }
  }
}
