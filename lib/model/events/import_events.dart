import 'package:moodtag/features/import/abstract_import_flow/flow/abstract_import_flow.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';

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

class ConfirmTagsForImport extends ImportEvent {
  final List<ImportedTag> selectedTags;

  const ConfirmTagsForImport(this.selectedTags);

  @override
  List<Object?> get props => [selectedTags];
}
