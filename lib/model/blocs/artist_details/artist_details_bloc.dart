import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/exceptions/user_readable/name_already_taken_exception.dart';
import 'package:moodtag/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/exceptions/user_readable/user_readable_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/spotify_auth/spotify_access_token_provider.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/events/spotify_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/screens/spotify_import/spotify_connector.dart';

import 'artist_details_state.dart';

class ArtistDetailsBloc extends Bloc<LibraryEvent, ArtistDetailsState> with ErrorStreamHandling {
  final Repository _repository;
  late final StreamSubscription _artistStreamSubscription;
  late final StreamSubscription _allTagsStreamSubscription;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();
  final SpotifyAccessTokenProvider _accessTokenProvider;
  StreamController<UserReadableException> errorStreamController = StreamController<UserReadableException>();

  ArtistDetailsBloc(this._repository, BuildContext mainContext, int artistId, this._accessTokenProvider)
      : super(ArtistDetailsState(artistId: artistId)) {
    on<StartedLoading<ArtistData>>(_handleStartedLoadingArtistData);
    on<DataUpdated<ArtistData>>(_handleArtistDataUpdated);
    on<ToggleTagEditMode>(_handleToggleTagEditModeEvent);
    on<CreateTags>(_handleCreateTagsEvent);
    on<ToggleTagForArtist>(_handleToggleTagForArtistEvent);
    on<PlayArtist>(_handlePlayArtistEvent);

    _allTagsStreamSubscription = this._repository.loadedDataAllTags.stream.listen((loadedDataValue) {
      // TODO Add an event instead
      emit(state.copyWith(loadedDataAllTags: loadedDataValue));
    });

    _artistStreamSubscription = _repository
        .getArtistDataById(artistId)
        .handleError((error) => add(DataUpdated<ArtistData>(error: error)))
        .listen((artistFromStream) => add(DataUpdated<ArtistData>(data: artistFromStream)));
    add(StartedLoading<ArtistData>());

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    _allTagsStreamSubscription.cancel();
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
      emit(state.copyWith(loadedArtistData: LoadedData.error('Artist data could not be loaded')));
    }
  }

  void _handleToggleTagEditModeEvent(ToggleTagEditMode event, Emitter<ArtistDetailsState> emit) {
    emit(state.copyWith(tagEditMode: !state.tagEditMode));
  }

  void _handleCreateTagsEvent(CreateTags event, Emitter<ArtistDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    if (exception is NameAlreadyTakenException) {
      errorStreamController.add(exception);
    }
  }

  void _handleToggleTagForArtistEvent(ToggleTagForArtist event, Emitter<ArtistDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleToggleTagForArtistEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _handlePlayArtistEvent(PlayArtist event, Emitter<ArtistDetailsState> emit) async {
    SpotifyAccessToken? accessToken = await _accessTokenProvider.getAccessToken();
    if (accessToken == null) {
      errorStreamController.add(ExternalServiceQueryException('Authorization to Spotify Web API failed.'));
      return;
    }

    try {
      playArtist(accessToken.token, event.artistData.artist);
    } catch (e) {
      errorStreamController.add(UnknownError('Could not start playback.', cause: e));
    }
  }
}
