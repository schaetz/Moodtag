import 'package:moodtag/model/entities/entities.dart';

import 'library_events.dart';

abstract class SpotifyEvent extends LibraryEvent {
  const SpotifyEvent();
}

class RequestUserAuthorization extends SpotifyEvent {
  final Function redirectAfterAuth;

  const RequestUserAuthorization({required this.redirectAfterAuth});

  @override
  List<Object?> get props => [redirectAfterAuth];
}

class LoginWebviewUrlChange extends SpotifyEvent {
  final String url;

  const LoginWebviewUrlChange(this.url);

  @override
  List<Object?> get props => [url];
}

// TODO Check if this is still needed
// class RequestAccessToken extends SpotifyEvent {
//   const RequestAccessToken();
//
//   @override
//   List<Object?> get props => [];
// }

class PlayArtist extends SpotifyEvent {
  final Artist artist;

  PlayArtist(this.artist);

  @override
  List<Object?> get props => [artist];
}
