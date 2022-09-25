import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/events/LibraryEvent.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/tag_events.dart';
import '../loading_status.dart';
import 'tags_list_state.dart';

class TagsListBloc extends Bloc<LibraryEvent, TagsListState> {
  final Repository _repository;
  late final StreamSubscription _tagsStreamSubscription;

  TagsListBloc(this._repository) : super(TagsListState()) {
    on<TagsListUpdated>(_mapTagsListUpdatedEventToState);

    _tagsStreamSubscription =
        _repository.getTags().listen((tagsListFromStream) => add(TagsListUpdated(tagsListFromStream)));
  }

  Future<void> close() async {
    _tagsStreamSubscription.cancel();
    super.close();
  }

  void _mapTagsListUpdatedEventToState(TagsListUpdated event, Emitter<TagsListState> emit) {
    if (event.tags != null) {
      emit(state.copyWith(tags: event.tags, loadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(loadingStatus: LoadingStatus.error));
    }
  }
}
