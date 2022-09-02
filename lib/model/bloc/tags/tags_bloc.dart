import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc/tags/tag_events.dart';
import 'package:moodtag/model/bloc/tags/tags_state.dart';
import 'package:moodtag/model/repository.dart';

class TagsBloc extends Bloc<TagEvent, TagsState> {
  final Repository repository;

  TagsBloc({this.repository}) : super(const TagsState()) {
    on<GetTags>(_mapGetTagsEventToState);
    on<SelectTag>(_mapSelectTagEventToState);
  }

  void _mapGetTagsEventToState(GetTags event, Emitter<TagsState> emit) async {
    emit(state.copyWith(status: TagsStatus.loading));
    try {
      final tags = await repository.getTags();
      emit(
        state.copyWith(
          status: TagsStatus.success,
          tags: tags,
        ),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(status: TagsStatus.error));
    }
  }

  void _mapSelectTagEventToState(event, Emitter<TagsState> emit) async {
    emit(
      state.copyWith(
        status: TagsStatus.selected,
        selectedTag: event.selectedTag,
      ),
    );
  }
}
