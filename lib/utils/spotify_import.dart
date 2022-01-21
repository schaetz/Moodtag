import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:moodtag/exceptions/spotify_import_exception.dart';

import 'helpers.dart';
import 'random_helper.dart';

// TODO Store these constants in a config file
const spotifyAccountsBaseUrl = 'accounts.spotify.com';
const authorizeSubroute = '/authorize';
const accessTokenSubroute = '/api/token';

const spotifyApiBaseUrl = 'api.spotify.com';
const followedArtistsSubroute = '/v1/me/following';

const clientId = 'c6f54e34aabb42a9b8add087c8642857';
const redirectUri = 'http://localhost:8888/callback';

String codeVerifier;

Uri getSpotifyAuthUri() {
  var state = getRandomString(16);
  var scope = 'user-read-private user-read-email';

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

void getFollowedArtists(String accessToken) async {
  final queryParameters = {
    'type': 'artist',
    'limit': '50',
  };
  final headers = {
    'Authorization': "Bearer $accessToken",
    'Content-Type': 'application/json',
  };

  final uri = Uri.https(spotifyApiBaseUrl, followedArtistsSubroute, queryParameters);
  final response = await http.get(uri, headers: headers);
  final responseBodyJSON = json.decode(response.body);

  if (isHttpRequestSuccessful(response)) {
    return responseBodyJSON;
  } else {
    final statusCode = response.statusCode;
    final message = responseBodyJSON['error']['message'];
    throw SpotifyImportException('Could not query followed artists: status $statusCode - message $message');
  }
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