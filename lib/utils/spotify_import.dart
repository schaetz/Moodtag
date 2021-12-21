import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'random_helper.dart';

// TODO Store these constants in a config file
const spotifyBaseUrl = 'accounts.spotify.com';
const authorizeSubroute = '/authorize';

var clientId = 'c6f54e34aabb42a9b8add087c8642857';
var redirectUri = 'http://localhost:8888/callback';

void getDataFromSpotify(context) async {
  final response = await http.get(getSpotifyAuthUri());
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
}

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
  return Uri.https(spotifyBaseUrl, authorizeSubroute, queryParameters);
}

bool isRedirectUri(Uri uri) {
  String uriWithoutQuery = uri.toString().replaceFirst(RegExp(r'\?.*$'), '');
  return uriWithoutQuery == redirectUri;
}

String _generateCodeChallenge() {
  final codeVerifier = getRandomStringOfRandomLength(43, 128, useSpecialChars: true);
  final digest = sha256.convert(utf8.encode(codeVerifier));
  return digest.toString();
}