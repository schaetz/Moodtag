import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_access_token_provider.dart';
import 'package:moodtag/features/import/spotify_import/connectors/spotify_connector.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config_factory.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/events/artist_events.dart';
import 'package:moodtag/shared/bloc/events/data_loading_events.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';
import 'package:moodtag/shared/bloc/events/spotify_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/bloc/extensions/error_handling/error_stream_handling.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_user_bloc_mixin.dart';
import 'package:moodtag/shared/bloc/helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/shared/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/shared/exceptions/user_readable/user_readable_exception.dart';

import 'artist_details_state.dart';

class ArtistDetailsBloc extends Bloc<LibraryEvent, ArtistDetailsState> with LibraryUserBlocMixin, ErrorStreamHandling {
  final artistByIdSubscriptionName = SubscriptionConfigFactory.artistByIdSubscriptionName;

  final Repository _repository;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();
  final SpotifyAccessTokenProvider _accessTokenProvider;
  StreamController<UserReadableException> errorStreamController = StreamController<UserReadableException>();

  ArtistDetailsBloc(this._repository, BuildContext mainContext, int artistId, this._accessTokenProvider)
      : super(ArtistDetailsState(artistId: artistId)) {
    useLibrary(_repository);

    add(RequestOrUpdateSubscription.withConfig(SubscriptionConfigFactory.getArtistByIdConfig(artistId)));
    add(RequestOrUpdateSubscription.withConfig(SubscriptionConfigFactory.getAllTagsListConfig()));

    on<ToggleTagEditMode>(_handleToggleTagEditModeEvent);
    on<CreateTags>(_handleCreateTagsEvent);
    on<ToggleTagForArtist>(_handleToggleTagForArtistEvent);
    on<PlayArtist>(_handlePlayArtistEvent);

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    super.close();
    closeErrorStreamController();
  }

  @override
  ArtistDetailsState getNewStateForReceivedData(
      SubscriptionConfig subscriptionConfig, LoadedData loadedData, Emitter<ArtistDetailsState> emit) {
    if (subscriptionConfig.name == artistByIdSubscriptionName) {
      return state.copyWith(loadedArtistData: LoadedData(loadedData.data, loadingStatus: loadedData.loadingStatus));
    }
    return super.getNewStateForReceivedData(subscriptionConfig, loadedData, emit);
  }

  @override
  ArtistDetailsState getNewStateForSubscriptionError(
      SubscriptionConfig subscriptionConfig, Object? object, StackTrace? stackTrace, Emitter<ArtistDetailsState> emit) {
    if (subscriptionConfig.name == artistByIdSubscriptionName) {
      return state.copyWith(loadedArtistData: LoadedData.error());
    }
    return super.getNewStateForSubscriptionError(subscriptionConfig, object, stackTrace, emit);
  }

  void _handleToggleTagEditModeEvent(ToggleTagEditMode event, Emitter<ArtistDetailsState> emit) {
    emit(state.copyWith(tagEditMode: !state.tagEditMode));
  }

  void _handleCreateTagsEvent(CreateTags event, Emitter<ArtistDetailsState> emit) async {
    final exception = await _createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    if (exception != null) {
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
      playArtist(accessToken.token, event.artist);
    } catch (e) {
      errorStreamController.add(UnknownError('Could not start playback.', cause: e));
    }
  }
}
