import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/external_service_query_exception.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/exceptions/unknown_error.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_bloc.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/spotify_auth/spotify_access_token_provider.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/spotify_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/screens/spotify_import/spotify_connector.dart';

import 'artist_details_state.dart';

class ArtistDetailsBloc extends AbstractEntityUserBloc<ArtistDetailsState> with ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _artistStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();
  final SpotifyAccessTokenProvider _accessTokenProvider;
  StreamController<UserReadableException> errorStreamController = StreamController<UserReadableException>();

  ArtistDetailsBloc(this._repository, BuildContext mainContext, int artistId, EntityLoaderBloc entityLoaderBloc,
      this._accessTokenProvider)
      : super(
            initialState: ArtistDetailsState(
                artistId: artistId, tagEditMode: false, loadedDataAllTags: entityLoaderBloc.state.loadedDataAllTags),
            entityLoaderBloc: entityLoaderBloc,
            useAllTagsStream: true) {
    on<StartedLoading<ArtistData>>(_handleStartedLoadingArtistData);
    on<DataUpdated<ArtistData>>(_handleArtistDataUpdated);
    on<ToggleTagEditMode>(_mapToggleTagEditModeEventToState);
    on<CreateTags>(_mapCreateTagsEventToState);
    on<ToggleTagForArtist>(_mapToggleTagForArtistEventToState);
    on<PlayArtist>(_mapPlayArtistEventToState);

    _artistStreamSubscription = _repository
        .getArtistDataById(artistId)
        .handleError((error) => add(DataUpdated<ArtistData>(error: error)))
        .listen((artistFromStream) => add(DataUpdated<ArtistData>(data: artistFromStream)));
    add(StartedLoading<ArtistData>());

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _artistStreamSubscription.cancel();
    super.close();
  }

  void _handleStartedLoadingArtistData(StartedLoading<ArtistData> event, Emitter<ArtistDetailsState> emit) {
    if (state.loadedArtistData.loadingStatus == LoadingStatus.initial) {
      emit(state.copyWith(loadedArtistData: LoadedData.loading()));
    }
  }

  void _handleArtistDataUpdated(DataUpdated<ArtistData> event, Emitter<ArtistDetailsState> emit) {
    if (event.data != null) {
      emit(state.copyWith(loadedArtistData: LoadedData.success(event.data)));
    } else {
      emit(state.copyWith(loadedArtistData: LoadedData.error()));
    }
  }

  void _mapToggleTagEditModeEventToState(ToggleTagEditMode event, Emitter<ArtistDetailsState> emit) {
    emit(state.copyWith(tagEditMode: !state.tagEditMode));
  }

  void _mapCreateTagsEventToState(CreateTags event, Emitter<ArtistDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    if (exception is NameAlreadyTakenException) {
      errorStreamController.add(exception);
    }
  }

  void _mapToggleTagForArtistEventToState(ToggleTagForArtist event, Emitter<ArtistDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleToggleTagForArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _mapPlayArtistEventToState(PlayArtist event, Emitter<ArtistDetailsState> emit) async {
    SpotifyAccessToken? accessToken = await _accessTokenProvider.getAccessToken();
    if (accessToken == null) {
      errorStreamController.add(ExternalServiceQueryException('Authorization to Spotify Web API failed.'));
      return;
    }

    try {
      playArtist(accessToken.token, event.artistData.artist);
    } catch (e) {
      errorStreamController.add(UnknownError('Could not start playback.'));
    }
  }
}
