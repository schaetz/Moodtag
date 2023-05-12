import 'package:moodtag/screens/spotify_import/spotify_connector.dart';

abstract class SpotifyAccessTokenProvider {
  Future<SpotifyAccessToken?> getAccessToken();
}
