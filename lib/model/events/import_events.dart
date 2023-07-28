import 'package:moodtag/screens/import_flow/abstract_import_flow.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';

import 'library_events.dart';

abstract class ImportEvent extends LibraryEvent {
  const ImportEvent();
}

class ReturnToPreviousImportScreen extends ImportEvent {
  final AbstractImportFlow importFlow;

  const ReturnToPreviousImportScreen(this.importFlow);

  @override
  List<Object?> get props => [importFlow];
}

class ChangeImportConfig extends ImportEvent {
  final Map<String, bool> selectedOptions;

  const ChangeImportConfig(this.selectedOptions);

  @override
  List<Object?> get props => [selectedOptions];
}

class ConfirmImportConfig extends ImportEvent {
  const ConfirmImportConfig();

  @override
  List<Object?> get props => [];
}

class ConfirmArtistsForImport extends ImportEvent {
  final List<ImportedArtist> selectedArtists;

  const ConfirmArtistsForImport(this.selectedArtists);

  @override
  List<Object?> get props => [selectedArtists];
}

class ConfirmGenreTagsForImport extends ImportEvent {
  final List<ImportedGenre> selectedGenres;

  const ConfirmGenreTagsForImport(this.selectedGenres);

  @override
  List<Object?> get props => [selectedGenres];
}

class CompleteImport extends ImportEvent {
  final List<ImportedArtist> selectedArtists;
  final List<ImportedGenre> selectedGenres;

  CompleteImport(this.selectedArtists, this.selectedGenres);

  @override
  List<Object?> get props => [selectedArtists, selectedGenres];
}
