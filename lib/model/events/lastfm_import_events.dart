import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_tag.dart';

import 'import_events.dart';

abstract class LastFmImportEvent extends ImportEvent {
  const LastFmImportEvent();
}

class CompleteLastFmImport extends ImportEvent {
  final List<ImportedArtist> selectedArtists;
  final List<ImportedTag> selectedTags;

  CompleteLastFmImport(this.selectedArtists, this.selectedTags);

  @override
  List<Object?> get props => [selectedArtists, selectedTags];
}
