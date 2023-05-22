import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_bloc.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/tag_events.dart';
import '../entity_loader/entity_user_mixin.dart';
import '../error_stream_handling.dart';
import 'tags_list_state.dart';

class TagsListBloc extends Bloc<LibraryEvent, TagsListState> with EntityUserMixin<TagsListState>, ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _allEntitiesStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagsListBloc(this._repository, BuildContext mainContext, EntityLoaderBloc entityLoaderBloc)
      : super(TagsListState(loadedDataAllTags: entityLoaderBloc.state.loadedDataAllTags)) {
    _allEntitiesStreamSubscription = subscribeToEntityLoader(entityLoaderBloc, useTags: true);

    onTagsListLoadingStatusChangedEmit();
    on<CreateTags>(_mapCreateTagsEventToState);
    on<DeleteTag>(_mapDeleteTagEventToState);

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _allEntitiesStreamSubscription.cancel();
    super.close();
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
