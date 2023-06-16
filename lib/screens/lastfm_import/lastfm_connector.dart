import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moodtag/exceptions/external_service_query_exception.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/utils/helpers.dart';

// TODO Store these constants in a config file
const lastFmApiBaseUrl = 'ws.audioscrobbler.com';
const lastFmBaseRoute = '/2.0';
const userInfoMethod = 'user.getinfo';

const apiKey = '732a14948d6c77c9cc9871d24b955fd8';

Future<LastFmAccount> getUserInfo(String username) async {
  final body = {'user': username, 'api_key': apiKey, 'method': userInfoMethod, 'format': 'json'};

  final uri = Uri.https(lastFmApiBaseUrl, lastFmBaseRoute);
  final response = await http.post(uri, body: body);
  final responseBodyJSON = json.decode(response.body);
  // TODO Remove debug logs
  print(response.statusCode);
  print(response.body);

  if (isHttpRequestSuccessful(response)) {
    return _extractLastFmAccountFromUserInfoResults(responseBodyJSON);
  } else {
    if (response.statusCode == 404) {
      return Future.error(
          ExternalServiceQueryException('There is no Last.fm user with the name "$username".'));
    } else {
      return Future.error(
          ExternalServiceQueryException('The Last.fm service could not be reached.'));
    }
  }
}

LastFmAccount _extractLastFmAccountFromUserInfoResults(dynamic responseBodyJSON) {
  if (!responseBodyJSON.containsKey('user')) {
    throw ExternalServiceQueryException(
        'The result obtained from the Last.fm API could not be processed.');
  }

  final userJSON = responseBodyJSON['user'];
  return LastFmAccount(
      accountName: userJSON['name'],
      realName: userJSON['realname'] ?? null,
      playCount: _parseNumberFromJson(userJSON, 'playcount'),
      artistCount: _parseNumberFromJson(userJSON, 'artist_count'),
      trackCount: _parseNumberFromJson(userJSON, 'track_count'),
      albumCount: _parseNumberFromJson(userJSON, 'album_count'),
      lastDataUpdate: DateTime.now().millisecondsSinceEpoch.toDouble());
}

int? _parseNumberFromJson(dynamic userJSON, String attribute) {
  if (!userJSON.containsKey(attribute)) {
    return null;
  }
  return int.parse(userJSON[attribute]);
}
