import 'package:moodtag/features/import/spotify_import/connectors/spotify_connector.dart';

abstract class SpotifyAccessTokenProvider {
  Future<SpotifyAccessToken?> getAccessToken();
}
