import 'package:moodtag/structs/imported_entities/imported_artist.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/lastfm_artist.dart';

import 'import_events.dart';

abstract class LastFmImportEvent extends ImportEvent {
  const LastFmImportEvent();
}

class ConfirmLastFmArtistsForImport extends ImportEvent {
  final List<LastFmArtist> selectedArtists;

  const ConfirmLastFmArtistsForImport(this.selectedArtists);

  @override
  List<Object?> get props => [selectedArtists];
}

class CompleteLastFmImport extends ImportEvent {
  final List<ImportedArtist> selectedArtists;
  final List<ImportedTag> selectedTags;

  CompleteLastFmImport(this.selectedArtists, this.selectedTags);

  @override
  List<Object?> get props => [selectedArtists, selectedTags];
}
