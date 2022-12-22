import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/events/LibraryEvent.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/tag_events.dart';
import '../loading_status.dart';
import 'tags_list_state.dart';

class TagsListBloc extends Bloc<LibraryEvent, TagsListState> {
  final Repository _repository;
  late final StreamSubscription _tagsStreamSubscription;
  final CreateEntityBlocHelper createEntityBlocHelper = CreateEntityBlocHelper();

  TagsListBloc(this._repository) : super(TagsListState()) {
    on<TagsListUpdated>(_mapTagsListUpdatedEventToState);
    on<OpenCreateTagDialog>(_mapOpenCreateTagDialogEventToState);
    on<CloseCreateTagDialog>(_mapCloseCreateTagDialogEventToState);
    on<CreateTags>(_mapCreateTagsEventToState);
    on<DeleteTag>(_mapDeleteTagEventToState);

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

  void _mapOpenCreateTagDialogEventToState(OpenCreateTagDialog event, Emitter<TagsListState> emit) {
    if (!state.showCreateTagDialog) _openCreateTagDialog(emit);
  }

  void _mapCloseCreateTagDialogEventToState(CloseCreateTagDialog event, Emitter<TagsListState> emit) {
    if (state.showCreateTagDialog) _closeCreateTagDialog(emit);
  }

  void _mapCreateTagsEventToState(CreateTags event, Emitter<TagsListState> emit) {
    createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    _closeCreateTagDialog(emit);
  }

  void _mapDeleteTagEventToState(DeleteTag event, Emitter<TagsListState> emit) {
    // TODO
  }

  void _openCreateTagDialog(Emitter<TagsListState> emit) {
    emit(state.copyWith(showCreateTagDialog: true));
  }

  void _closeCreateTagDialog(Emitter<TagsListState> emit) {
    emit(state.copyWith(showCreateTagDialog: false));
  }
}
