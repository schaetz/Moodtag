import 'package:moodtag/screens/spotify_import/spotify_import_config_screen.dart';
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

class ConfirmConfigForSpotifyImport extends SpotifyEvent {
  final Map<SpotifyImportOption, bool> selectedOptions;

  const ConfirmConfigForSpotifyImport(this.selectedOptions);

  @override
  List<Object?> get props => [selectedOptions];
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
