import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/repository.dart';

import '../../events/tag_events.dart';
import '../loading_status.dart';
import 'tags_list_state.dart';

class TagsListBloc extends Bloc<TagEvent, TagsListState> {
  final Repository repository;

  TagsListBloc({this.repository}) : super(const TagsListState()) {
    on<GetTags>(_mapGetTagsEventToState);
  }

  void _mapGetTagsEventToState(GetTags event, Emitter<TagsListState> emit) async {
    emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    try {
      final tags = await repository.getTags();
      emit(
        state.copyWith(
          loadingStatus: LoadingStatus.success,
          tags: tags,
        ),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(loadingStatus: LoadingStatus.error));
    }
  }
}
