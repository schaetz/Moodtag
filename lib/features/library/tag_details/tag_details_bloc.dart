import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/library_query_filter.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/model/repository/subscription_config.dart';
import 'package:moodtag/shared/bloc/error_handling/error_stream_handling.dart';
import 'package:moodtag/shared/bloc/helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/shared/bloc/library_user/library_user_bloc_mixin.dart';

import 'tag_details_state.dart';

class TagDetailsBloc extends Bloc<LibraryEvent, TagDetailsState> with LibraryUserBlocMixin, ErrorStreamHandling {
  static const tagByIdSubscriptionName = 'tag_by_id';
  static const artistsWithTagSubscriptionName = 'artists_with_tag';

  final Repository _repository;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  TagDetailsBloc(this._repository, BuildContext mainContext, int tagId) : super(TagDetailsState(tagId: tagId)) {
    useLibrary(_repository);
    add(RequestOrUpdateSubscription(TagData, name: tagByIdSubscriptionName, filter: LibraryQueryFilter(id: tagId)));
    add(RequestOrUpdateSubscription(ArtistsList));

    on<AddArtistsForTag>(_handleAddArtistsForTagEvent);
    on<RemoveTagFromArtist>(_handleRemoveTagFromArtistEvent);
    on<ToggleArtistsForTagChecklist>(_handleToggleArtistsForTagChecklistEvent);
    on<ToggleTagForArtist>(_handleToggleTagForArtistEvent);

    setupErrorHandler(mainContext);
  }

  @override
  void onDataReceived(SubscriptionConfig subscriptionConfig, LoadedData loadedData, Emitter<TagDetailsState> emit) {
    super.onDataReceived(subscriptionConfig, loadedData, emit);
    if (subscriptionConfig.name == tagByIdSubscriptionName) {
      emit(state.copyWith(loadedTagData: LoadedData(loadedData.data, loadingStatus: loadedData.loadingStatus)));
      if (loadedData.loadingStatus.isSuccess && state.artistsWithThisTagOnly.loadingStatus.isInitial) {
        final tagData = loadedData.data as TagData;
        add(RequestOrUpdateSubscription(ArtistsList,
            name: artistsWithTagSubscriptionName, filter: LibraryQueryFilter(entityFilters: {tagData.tag})));
      }
    } else if (subscriptionConfig.name == artistsWithTagSubscriptionName) {
      emit(
          state.copyWith(artistsWithThisTagOnly: LoadedData(loadedData.data, loadingStatus: loadedData.loadingStatus)));
    }
  }

  @override
  void onStreamSubscriptionError(
      SubscriptionConfig subscriptionConfig, Object object, StackTrace stackTrace, Emitter<TagDetailsState> emit) {
    super.onStreamSubscriptionError(subscriptionConfig, object, stackTrace, emit);
    if (subscriptionConfig.name == tagByIdSubscriptionName) {
      emit(state.copyWith(loadedTagData: LoadedData.error()));
    } else if (subscriptionConfig.name == artistsWithTagSubscriptionName) {
      emit(state.copyWith(artistsWithThisTagOnly: LoadedData.error()));
    }
  }

  void _handleAddArtistsForTagEvent(AddArtistsForTag event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleAddArtistsForTagEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _handleRemoveTagFromArtistEvent(RemoveTagFromArtist event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleRemoveTagFromArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _handleToggleArtistsForTagChecklistEvent(
      ToggleArtistsForTagChecklist event, Emitter<TagDetailsState> emit) async {
    emit(state.copyWith(checklistMode: !state.checklistMode));
  }

  void _handleToggleTagForArtistEvent(ToggleTagForArtist event, Emitter<TagDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleToggleTagForArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }
}
