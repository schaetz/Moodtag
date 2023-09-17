import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/name_already_taken_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_bloc.dart';
import 'package:moodtag/model/repository/repository.dart';

import '../../events/tag_events.dart';
import '../entity_loader/abstract_entity_user_bloc.dart';
import '../error_stream_handling.dart';
import 'tags_list_state.dart';

class TagsListBloc extends AbstractEntityUserBloc<TagsListState> with ErrorStreamHandling {
  final Repository _repository;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagsListBloc(this._repository, BuildContext mainContext, EntityLoaderBloc entityLoaderBloc)
      : super(
            initialState: TagsListState(loadedDataAllTags: entityLoaderBloc.state.loadedDataAllTags),
            entityLoaderBloc: entityLoaderBloc,
            useAllTagsStream: true) {
    on<CreateTags>(_handleCreateTagsEvent);
    on<DeleteTag>(_handleDeleteTagEvent);

    setupErrorHandler(mainContext);
  }

  void _handleCreateTagsEvent(CreateTags event, Emitter<TagsListState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    if (exception is NameAlreadyTakenException) {
      errorStreamController.add(exception);
    }
  }

  void _handleDeleteTagEvent(DeleteTag event, Emitter<TagsListState> emit) async {
    final deleteTagResponse = await _repository.deleteTag(event.tag);
    if (deleteTagResponse.didFail()) {
      errorStreamController.add(deleteTagResponse.getUserFeedbackException());
    }
  }
}
