import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:moodtag/exceptions/spotify_import_exception.dart';
import 'package:moodtag/structs/imported_artists_set.dart';
import 'package:moodtag/structs/imported_artist.dart';

import 'helpers.dart';
import 'random_helper.dart';

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

String codeVerifier;

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

Future<dynamic> getAccessToken(String authorizationCode) async {
  final body = {
    'grant_type': 'authorization_code',
    'code': authorizationCode,
    'redirect_uri': redirectUri,
    'client_id': clientId,
    'code_verifier': codeVerifier,
  };

  final uri = Uri.https(spotifyAccountsBaseUrl, accessTokenSubroute);
  final response = await http.post(uri, body: body);
  final responseBodyJSON = json.decode(response.body);

  if (isHttpRequestSuccessful(response)) {
    return responseBodyJSON;
  } else {
    throw SpotifyImportException('Could not acquire an access token for the Spotify Web API.');
  }
}

Future<ImportedArtistsSet> getFollowedArtists(String accessToken) async {
  final queryParameters = {
    'type': 'artist',
    'limit': '50',
  };

  final uri = Uri.https(spotifyApiBaseUrl, followedArtistsSubroute, queryParameters);
  final response = await http.get(uri, headers: _getHeader(accessToken));

  if (!isHttpRequestSuccessful(response)) {
    throw SpotifyImportException(_getRequestErrorMessage(response));
  }

  final responseBodyStructure = json.decode(response.body);
  Set<ImportedArtist> followedArtists;
  try {
    followedArtists = Set<ImportedArtist>.from(
      responseBodyStructure['artists']['items']?.map(
        (item) => ImportedArtist(item['name'], Set.from(item['genres']))
      )
    );
  } catch (error) {
    throw SpotifyImportException('The Spotify data has an unknown structure.');
  }

  if (followedArtists == null) {
    throw SpotifyImportException('The Spotify data could not be processed.');
  }

  return ImportedArtistsSet.from(followedArtists);
}

Future<ImportedArtistsSet> getTopArtists(String accessToken, int limit, int offset) async {
  final queryParameters = {
    'limit': limit.toString(),
    'offset': offset.toString(),
    'time_range': 'medium_term',
  };

  final uri = Uri.https(spotifyApiBaseUrl, topArtistsSubroute, queryParameters);
  final response = await http.get(uri, headers: _getHeader(accessToken));

  if (!isHttpRequestSuccessful(response)) {
    throw SpotifyImportException(_getRequestErrorMessage(response));
  }

  final responseBodyMap = json.decode(response.body);
  Set<ImportedArtist> topArtists;
  try {
    topArtists = Set<ImportedArtist>.from(
      responseBodyMap['items']?.map(
        (item) => ImportedArtist(item['name'], Set.from(item['genres']))
      )
    );
  } catch (error) {
    throw SpotifyImportException('The Spotify data has an unknown structure.');
  }

  if (topArtists == null) {
    throw SpotifyImportException('The Spotify data could not be processed.');
  }

  return ImportedArtistsSet.from(topArtists);
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
  final bytes = utf8.encode(codeVerifier);
  final hashed = sha256.convert(bytes);
  final base64UrlEncoded = base64Url.encode(hashed.bytes)
      .replaceAll("=", "")
      .replaceAll("+", "-")
      .replaceAll("/", "_");
  return base64UrlEncoded;
}

Object _getHeader(String accessToken) {
  return {
    'Authorization': "Bearer $accessToken",
    'Content-Type': 'application/json',
  };
}