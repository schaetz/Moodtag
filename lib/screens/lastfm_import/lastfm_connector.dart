import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:moodtag/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/screens/lastfm_import/lastfm_import_period.dart';
import 'package:moodtag/structs/imported_entities/lastfm_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';
import 'package:moodtag/utils/helpers.dart';

// TODO Store these constants in a config file
const lastFmApiBaseUrl = 'ws.audioscrobbler.com';
const lastFmBaseRoute = '/2.0';
const moodtagUserAgent = 'Moodtag/0.1';
const methodUserInfo = 'user.getinfo';
const methodGetTopArtists = 'user.gettopartists';

const apiKey = '732a14948d6c77c9cc9871d24b955fd8';

Future<LastFmAccount> getUserInfo(String username) async {
  final queryParameters = {'user': username, 'api_key': apiKey, 'method': methodUserInfo, 'format': 'json'};

  final uri = Uri.https(lastFmApiBaseUrl, lastFmBaseRoute, queryParameters);
  final response = await http.get(uri, headers: _getHeaderWithUserAgent());
  final responseBodyJSON = json.decode(response.body);

  if (isHttpRequestSuccessful(response)) {
    return _extractLastFmAccountFromUserInfoResults(responseBodyJSON);
  } else {
    if (response.statusCode == 404) {
      return Future.error(ExternalServiceQueryException('There is no Last.fm user with the name "$username".'));
    } else {
      return Future.error(ExternalServiceQueryException('The Last.fm service could not be reached.'));
    }
  }
}

Future<UniqueNamedEntitySet<LastFmArtist>> getTopArtists(String username, LastFmImportPeriod period, int limit) async {
  final queryParameters = {
    'user': username,
    'api_key': apiKey,
    'method': methodGetTopArtists,
    'limit': limit.toString(),
    'period': getLastFmImportPeriodString(period),
    'format': 'json'
  };

  final uri = Uri.https(lastFmApiBaseUrl, lastFmBaseRoute, queryParameters);
  final response = await http.get(uri, headers: _getHeaderWithUserAgent());

  if (!isHttpRequestSuccessful(response)) {
    throw ExternalServiceQueryException(_getRequestErrorMessage(response));
  }

  final responseBodyMap = json.decode(response.body);
  Set<LastFmArtist> topArtists;
  try {
    topArtists = Set<LastFmArtist>.from(
        responseBodyMap['topartists']?['artist']?.map((item) => LastFmArtist(item['name'], item['playcount'])));
  } catch (error) {
    throw ExternalServiceQueryException('The Spotify data has an unknown structure.', cause: error);
  }

  return UniqueNamedEntitySet<LastFmArtist>.from(topArtists);
}

String _getRequestErrorMessage(Response response) {
  final statusCode = response.statusCode;
  // TODO Extract error message from response, as is done in SpotifyConnector

  return 'Could not query artists: status $statusCode';
}

LastFmAccount _extractLastFmAccountFromUserInfoResults(dynamic responseBodyJSON) {
  if (!responseBodyJSON.containsKey('user')) {
    throw ExternalServiceQueryException('The result obtained from the Last.fm API could not be processed.');
  }

  final userJSON = responseBodyJSON['user'];
  return LastFmAccount(
      accountName: userJSON['name'],
      realName: userJSON['realname'] ?? null,
      playCount: _parseNumberFromJson(userJSON, 'playcount'),
      artistCount: _parseNumberFromJson(userJSON, 'artist_count'),
      trackCount: _parseNumberFromJson(userJSON, 'track_count'),
      albumCount: _parseNumberFromJson(userJSON, 'album_count'),
      lastAccountUpdate: DateTime.now().millisecondsSinceEpoch.toDouble());
}

int? _parseNumberFromJson(dynamic userJSON, String attribute) {
  if (!userJSON.containsKey(attribute)) {
    return null;
  }
  return int.parse(userJSON[attribute]);
}

Map<String, String> _getHeaderWithUserAgent() {
  return {'User-Agent': moodtagUserAgent};
}
