import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_tag.dart';

abstract class SpotifyImportEvent extends ImportEvent {
  const SpotifyImportEvent();
}

class ConfirmGenreTagsForImport extends ImportEvent {
  final List<ImportedTag> selectedGenres;

  const ConfirmGenreTagsForImport(this.selectedGenres);

  @override
  List<Object?> get props => [selectedGenres];
}

class CompleteSpotifyImport extends ImportEvent {
  final List<ImportedArtist> selectedArtists;
  final List<ImportedTag> selectedGenres;

  CompleteSpotifyImport(this.selectedArtists, this.selectedGenres);

  @override
  List<Object?> get props => [selectedArtists, selectedGenres];
}
