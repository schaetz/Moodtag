import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'random_helper.dart';

const spotifyBaseUrl = 'accounts.spotify.com';
const authorizeSubroute = '/authorize';

var client_id = 'c6f54e34aabb42a9b8add087c8642857';
var redirect_uri = 'http://localhost:8888/callback';

void getDataFromSpotify() async {
  var state = getRandomString(16);
  var scope = 'user-read-private user-read-email';

  final queryParameters = {
    'response_type': 'code',
    'client_id': client_id,
    'scope': scope,
    'redirect_uri': redirect_uri,
    'state': state,
    'code_challenge_method': 'S256',
    'code_challenge': _generateCodeChallenge(),
  };
  final uri = Uri.https(spotifyBaseUrl, authorizeSubroute, queryParameters);
  final response = await http.get(uri);
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
}

String _generateCodeChallenge() {
  final codeVerifier = getRandomStringOfRandomLength(43, 128, useSpecialChars: true);
  final digest = sha256.convert(utf8.encode(codeVerifier));
  return digest.toString();
}