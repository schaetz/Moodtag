import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_access_token_provider.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_auth_state.dart';
import 'package:moodtag/features/import/spotify_import/connectors/spotify_connector.dart' as connector;
import 'package:moodtag/features/import/spotify_import/connectors/spotify_connector.dart';
import 'package:moodtag/shared/bloc/events/spotify_events.dart';
import 'package:moodtag/shared/bloc/extensions/error_handling/error_stream_handling.dart';
import 'package:moodtag/shared/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/unknown_error.dart';

class SpotifyAuthBloc extends Bloc<SpotifyEvent, SpotifyAuthState>
    with ErrorStreamHandling
    implements SpotifyAccessTokenProvider {
  final BuildContext mainContext;

  SpotifyAuthBloc(this.mainContext) : super(SpotifyAuthState()) {
    on<RequestUserAuthorization>(_handleRequestUserAuthorizationEvent);
    on<LoginWebviewUrlChange>(_handleLoginWebviewUrlChangeEvent);
    // on<RequestAccessToken>(_handleRequestAccessTokenEvent); TODO Check if this is still needed

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    super.close();
    closeErrorStreamController();
  }

  Future<SpotifyAccessToken?> getAccessToken() async {
    SpotifyAccessToken? accessToken = state.spotifyAccessToken;
    if (accessToken == null || accessToken.hasExpired()) {
      // this.add(RequestAccessToken()); TODO Check if this is still needed
      await stream
          .timeout(Duration(seconds: 1), onTimeout: (_) {
            accessToken = null;
          })
          .firstWhere((newState) => newState.spotifyAccessToken != null && newState.spotifyAccessToken != accessToken)
          .then((newState) {
            accessToken = newState.spotifyAccessToken;
          });
    }

    return accessToken;
  }

  void _handleRequestUserAuthorizationEvent(RequestUserAuthorization event, Emitter<SpotifyAuthState> emit) {
    emit(state.copyWith(redirectRoute: event.redirectAfterAuth));
  }

  void _handleLoginWebviewUrlChangeEvent(LoginWebviewUrlChange event, Emitter<SpotifyAuthState> emit) async {
    Uri uri = Uri.parse(event.url);
    print(uri.authority);
    print(uri.queryParameters);
    print('uri: ' + uri.toString());
    if (isRedirectUri(uri)) {
      final authorizationCode = uri.queryParameters.containsKey('code') ? uri.queryParameters['code'] : null;
      if (authorizationCode == null) {
        errorStreamController.add(UnknownError('An error occurred trying to connect to the Spotify API.'));
      } else {
        Function? currentRedirect = state.redirect;
        SpotifyAccessToken? newAccessToken;
        try {
          newAccessToken = await _getAccessTokenWithoutStateUpdate(authorizationCode: authorizationCode);
        } catch (e) {
          errorStreamController
              .add(ExternalServiceQueryException('Could not retrieve an access token for Spotify API.', cause: e));
        }

        if (newAccessToken != null && newAccessToken != state.spotifyAccessToken) {
          emit(state.copyWith(
              spotifyAuthCode: authorizationCode, spotifyAccessToken: newAccessToken, redirectRoute: null));
        } else {
          emit(state.copyWith(spotifyAuthCode: authorizationCode, redirectRoute: null));
        }
        _redirectAfterSuccessfulAuthorization(currentRedirect);
      }
    }
  }

  // TODO Check if this is still needed
  // void _handleRequestAccessTokenEvent(RequestAccessToken event, Emitter<SpotifyAuthState> emit) async {
  //   try {
  //     SpotifyAccessToken accessToken = await _getAccessTokenWithoutStateUpdate();
  //     if (accessToken != state.spotifyAccessToken) {
  //       emit(state.copyWith(spotifyAccessToken: accessToken));
  //     }
  //   } catch (e) {
  //     throw ExternalServiceQueryException('The authorization to the Spotify Web API failed.');
  //   }
  // }

  void _redirectAfterSuccessfulAuthorization(Function? redirect) {
    if (redirect != null) {
      redirect();
    }
  }

  Future<SpotifyAccessToken> _getAccessTokenWithoutStateUpdate({String? authorizationCode}) async {
    final usedAuthCode = authorizationCode == null ? state.spotifyAuthCode : authorizationCode;
    if (usedAuthCode == null) {
      throw ExternalServiceQueryException('The authorization to the Spotify Web API failed.');
    }

    try {
      if (state.spotifyAccessToken == null) {
        print('Get new Spotify access token');
        return await connector.getAccessToken(usedAuthCode);
      } else if (!state.hasAccessTokenExpired()) {
        print('Use existing access token from Spotify: ${state.spotifyAccessToken!.token}');
        return state.spotifyAccessToken!;
      } else if (state.spotifyAccessToken!.refreshToken != null) {
        print('Spotify access token expired - Refresh access token');
        return await connector.refreshAccessToken(state.spotifyAccessToken!.refreshToken!);
      } else {
        print('Spotify access token expired, no refresh token given - Try to acquire a new access token');
        return await connector.getAccessToken(usedAuthCode);
      }
    } catch (e) {
      throw ExternalServiceQueryException('The authorization to the Spotify Web API failed.', cause: e);
    }
  }
}
