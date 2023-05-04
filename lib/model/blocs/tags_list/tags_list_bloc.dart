import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/tag_events.dart';
import '../error_stream_handling.dart';
import '../loading_status.dart';
import 'tags_list_state.dart';

class TagsListBloc extends Bloc<LibraryEvent, TagsListState> with ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _tagsStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagsListBloc(this._repository, BuildContext mainContext) : super(TagsListState()) {
    on<TagsListPlusUpdated>(_mapTagsListUpdatedEventToState);
    on<CreateTags>(_mapCreateTagsEventToState);
    on<DeleteTag>(_mapDeleteTagEventToState);

    _tagsStreamSubscription = _repository
        .getTagsWithArtistFreq()
        .handleError((error) => add(TagsListPlusUpdated(error: error)))
        .listen((tagsListFromStream) => add(TagsListPlusUpdated(tagsWithArtistFreq: tagsListFromStream)));

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _tagsStreamSubscription.cancel();
    super.close();
  }

  void _mapTagsListUpdatedEventToState(TagsListPlusUpdated event, Emitter<TagsListState> emit) {
    if (event.tagsWithArtistFreq != null) {
      emit(state.copyWith(tagsWithArtistFreq: event.tagsWithArtistFreq, loadingStatus: LoadingStatus.success));
    } else {
      emit(state.copyWith(loadingStatus: LoadingStatus.error));
    }
  }

  void _mapCreateTagsEventToState(CreateTags event, Emitter<TagsListState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    if (exception is NameAlreadyTakenException) {
      errorStreamController.add(exception);
    }
  }

  void _mapDeleteTagEventToState(DeleteTag event, Emitter<TagsListState> emit) async {
    final deleteTagResponse = await _repository.deleteTag(event.tag);
    if (deleteTagResponse.didFail()) {
      errorStreamController.add(deleteTagResponse.getUserFeedbackException());
    }
  }
}
