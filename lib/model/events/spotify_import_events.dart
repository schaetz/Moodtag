import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/spotify_artist.dart';

abstract class SpotifyImportEvent extends ImportEvent {
  const SpotifyImportEvent();
}

class ConfirmSpotifyArtistsForImport extends ImportEvent {
  final List<SpotifyArtist> selectedArtists;

  const ConfirmSpotifyArtistsForImport(this.selectedArtists);

  @override
  List<Object?> get props => [selectedArtists];
}

class ConfirmGenreTagsForImport extends ImportEvent {
  final List<ImportedTag> selectedGenres;

  const ConfirmGenreTagsForImport(this.selectedGenres);

  @override
  List<Object?> get props => [selectedGenres];
}

class CompleteSpotifyImport extends ImportEvent {
  final List<SpotifyArtist> selectedArtists;
  final List<ImportedTag> selectedGenres;

  CompleteSpotifyImport(this.selectedArtists, this.selectedGenres);

  @override
  List<Object?> get props => [selectedArtists, selectedGenres];
}
