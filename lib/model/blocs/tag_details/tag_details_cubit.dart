import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/repository.dart';

import 'tag_details_state.dart';

class TagDetailsCubit extends Cubit<TagDetailsState> {
  final Repository repository;

  TagDetailsCubit({this.repository, int tagId}) : super(TagDetailsState(tagId: tagId));

  void initialize() async {
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

    emit(state.copyWith(artistsListLoadingStatus: LoadingStatus.loading));
  }

  void _loadArtistsWithTag() async {
    emit(
      state.copyWith(artistsListLoadingStatus: LoadingStatus.loading),
    );
    try {
      final tagsForTag = await repository.getTags();
      emit(
        state.copyWith(artistsListLoadingStatus: LoadingStatus.success, artistsWithTag: tagsForTag),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(artistsListLoadingStatus: LoadingStatus.error));
    }
  }

  void toggleTagEditMode() {
    emit(state.copyWith(tagEditMode: !state.tagEditMode));
  }
}
