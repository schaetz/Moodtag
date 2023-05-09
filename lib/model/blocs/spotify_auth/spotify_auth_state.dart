import 'package:equatable/equatable.dart';
import 'package:moodtag/screens/spotify_import/spotify_connector.dart';

class SpotifyAuthState extends Equatable {
  final String? spotifyAuthCode;
  final SpotifyAccessToken? spotifyAccessToken;
  final Function? redirect;

  const SpotifyAuthState({
    this.spotifyAuthCode,
    this.spotifyAccessToken,
    this.redirect,
  });

  bool hasAccessTokenExpired() {
    if (spotifyAccessToken == null) {
      return false;
    }
    return spotifyAccessToken!.hasExpired();
  }

  @override
  List<Object?> get props => [spotifyAuthCode, spotifyAccessToken, redirect];

  SpotifyAuthState copyWith({
    String? spotifyAuthCode,
    SpotifyAccessToken? spotifyAccessToken,
    Function? redirectRoute,
  }) {
    return SpotifyAuthState(
      spotifyAuthCode: spotifyAuthCode ?? this.spotifyAuthCode,
      spotifyAccessToken: spotifyAccessToken ?? this.spotifyAccessToken,
      redirect: redirectRoute ?? this.redirect,
    );
  }
}
