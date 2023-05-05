import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';

import 'library_events.dart';

abstract class SpotifyEvent extends LibraryEvent {
  const SpotifyEvent();
}

class LoginWebviewUrlChange extends SpotifyEvent {
  final String url;

  const LoginWebviewUrlChange(this.url);

  @override
  List<Object?> get props => [url];
}

class ChangeConfigForSpotifyImport extends SpotifyEvent {
  final Map<String, bool> selectedOptions;

  const ChangeConfigForSpotifyImport(this.selectedOptions);

  @override
  List<Object?> get props => [selectedOptions];
}

class ConfirmConfigForSpotifyImport extends SpotifyEvent {
  const ConfirmConfigForSpotifyImport();

  @override
  List<Object?> get props => [];
}

class ConfirmArtistsForSpotifyImport extends SpotifyEvent {
  final List<ImportedArtist> selectedArtists;

  const ConfirmArtistsForSpotifyImport(this.selectedArtists);

  @override
  List<Object?> get props => [selectedArtists];
}

class ConfirmGenreTagsForSpotifyImport extends SpotifyEvent {
  final List<ImportedGenre> selectedGenres;

  const ConfirmGenreTagsForSpotifyImport(this.selectedGenres);

  @override
  List<Object?> get props => [selectedGenres];
}

class CompleteSpotifyImport extends SpotifyEvent {
  @override
  List<Object?> get props => [];
}
