import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:moodtag/exceptions/external_service_query_exception.dart';
import 'package:moodtag/exceptions/unknown_error.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';
import 'package:moodtag/utils/helpers.dart';
import 'package:moodtag/utils/random_helper.dart';

// TODO Store these constants in a config file
const spotifyAccountsBaseUrl = 'accounts.spotify.com';
const authorizeSubroute = '/authorize';
const accessTokenSubroute = '/api/token';

const spotifyApiBaseUrl = 'api.spotify.com';
const topArtistsSubroute = '/v1/me/top/artists';
const followedArtistsSubroute = '/v1/me/following';

const clientId = 'c6f54e34aabb42a9b8add087c8642857';
const redirectUri = 'http://localhost:8888/callback';

const topItemsLimit = 50;

String? codeVerifier;

Uri getSpotifyAuthUri() {
  var state = getRandomString(16);
  var scope = 'user-follow-read user-top-read user-library-read';

  final queryParameters = {
    'response_type': 'code',
    'client_id': clientId,
    'scope': scope,
    'redirect_uri': redirectUri,
    'state': state,
    'code_challenge_method': 'S256',
    'code_challenge': _generateCodeChallenge(),
  };
  return Uri.https(spotifyAccountsBaseUrl, authorizeSubroute, queryParameters);
}

bool isRedirectUri(Uri uri) {
  String uriWithoutQuery = uri.toString().replaceFirst(RegExp(r'\?.*$'), '');
  return uriWithoutQuery == redirectUri;
}

class SpotifyAccessToken {
  String token;
  DateTime? expiration;
  String? refreshToken;

  SpotifyAccessToken({required this.token, this.expiration, this.refreshToken});

  bool hasExpired() {
    return expiration == null || DateTime.now().isAfter(expiration!);
  }
}

Future<SpotifyAccessToken> getAccessToken(String authorizationCode) async {
  final body = {
    'grant_type': 'authorization_code',
    'code': authorizationCode,
    'redirect_uri': redirectUri,
    'client_id': clientId,
    'code_verifier': codeVerifier,
  };

  final uri = Uri.https(spotifyAccountsBaseUrl, accessTokenSubroute);
  final response = await http.post(uri, body: body, headers: _getHeaderFormUrlEncoded());

  if (isHttpRequestSuccessful(response)) {
    SpotifyAccessToken? accessToken = _extractAccessTokenFromJson(response.body);
    if (accessToken == null) {
      throw ExternalServiceQueryException(
          'Could not acquire an access token for the Spotify Web API: Unexpected response');
    }

    return accessToken;
  } else {
    throw ExternalServiceQueryException('Could not acquire an access token for the Spotify Web API.');
  }
}

Future<SpotifyAccessToken> refreshAccessToken(String refreshToken) async {
  final body = {
    'grant_type': 'refresh_token',
    'refresh_token': refreshToken,
    'client_id': clientId,
  };

  final uri = Uri.https(spotifyAccountsBaseUrl, accessTokenSubroute);
  final response = await http.post(uri, body: body, headers: _getHeaderFormUrlEncoded());

  if (isHttpRequestSuccessful(response)) {
    SpotifyAccessToken? accessToken = _extractAccessTokenFromJson(response.body);
    if (accessToken == null) {
      throw ExternalServiceQueryException(
          'Could not refresh the access token for the Spotify Web API: Unexpected response');
    }

    return accessToken;
  } else {
    throw ExternalServiceQueryException('Could not refresh the access token for the Spotify Web API.');
  }
}

SpotifyAccessToken? _extractAccessTokenFromJson(String responseBody) {
  final responseBodyJSON = json.decode(responseBody);
  String? token = responseBodyJSON.containsKey('access_token') ? responseBodyJSON['access_token'] : null;
  if (token == null) {
    return null;
  }

  final expiration = responseBodyJSON.containsKey('expires_in')
      ? DateTime.now().add(Duration(seconds: responseBodyJSON['expires_in']))
      : null;
  final refreshToken = responseBodyJSON.containsKey('refresh_token') ? responseBodyJSON['refresh_token'] : null;

  return SpotifyAccessToken(token: token, expiration: expiration, refreshToken: refreshToken);
}

Future<UniqueNamedEntitySet<ImportedArtist>> getFollowedArtists(String accessToken) async {
  final queryParameters = {
    'type': 'artist',
    'limit': '50',
  };

  final uri = Uri.https(spotifyApiBaseUrl, followedArtistsSubroute, queryParameters);
  final response = await http.get(uri, headers: _getHeaderWithAccessToken(accessToken));

  if (!isHttpRequestSuccessful(response)) {
    throw ExternalServiceQueryException(_getRequestErrorMessage(response));
  }

  final responseBodyStructure = json.decode(response.body);
  Set<ImportedArtist> followedArtists;
  try {
    followedArtists = Set<ImportedArtist>.from(responseBodyStructure['artists']['items']
        ?.map((item) => ImportedArtist(item['name'], Set.from(item['genres']), item['id'])));
  } catch (error) {
    throw ExternalServiceQueryException('The Spotify data has an unknown structure.');
  }

  return UniqueNamedEntitySet<ImportedArtist>.from(followedArtists);
}

Future<UniqueNamedEntitySet<ImportedArtist>> getTopArtists(String accessToken, int limit, int offset) async {
  final queryParameters = {
    'limit': limit.toString(),
    'offset': offset.toString(),
    'time_range': 'medium_term',
  };

  final uri = Uri.https(spotifyApiBaseUrl, topArtistsSubroute, queryParameters);
  final response = await http.get(uri, headers: _getHeaderWithAccessToken(accessToken));

  if (!isHttpRequestSuccessful(response)) {
    throw ExternalServiceQueryException(_getRequestErrorMessage(response));
  }

  final responseBodyMap = json.decode(response.body);
  Set<ImportedArtist> topArtists;
  try {
    topArtists = Set<ImportedArtist>.from(
        responseBodyMap['items']?.map((item) => ImportedArtist(item['name'], Set.from(item['genres']), item['id'])));
  } catch (error) {
    throw ExternalServiceQueryException('The Spotify data has an unknown structure.');
  }

  return UniqueNamedEntitySet<ImportedArtist>.from(topArtists);
}

String _getRequestErrorMessage(Response response) {
  final statusCode = response.statusCode;
  var messageAppendix = '';

  try {
    final responseBodyJSON = json.decode(response.body);
    messageAppendix = '- message ' + responseBodyJSON['error']['message'];
  } catch (e) {
    // FormatException is thrown for statusCode 403 Forbidden
  }

  return 'Could not query artists: status $statusCode $messageAppendix';
}

String _generateCodeChallenge() {
  codeVerifier = getRandomStringOfRandomLength(43, 128, useSpecialChars: true);
  if (codeVerifier == null) throw UnknownError('An error occurred trying to connect to the Spotify API.');
  final bytes = utf8.encode(codeVerifier!);
  final hashed = sha256.convert(bytes);
  final base64UrlEncoded = base64Url.encode(hashed.bytes).replaceAll("=", "").replaceAll("+", "-").replaceAll("/", "_");
  return base64UrlEncoded;
}

Map<String, String> _getHeaderFormUrlEncoded() {
  return {
    'Content-Type': 'application/x-www-form-urlencoded',
  };
}

Map<String, String> _getHeaderWithAccessToken(String accessToken) {
  return {
    'Authorization': "Bearer $accessToken",
    'Content-Type': 'application/json',
  };
}
