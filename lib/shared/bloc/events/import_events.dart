import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_option.dart';
import 'package:moodtag/features/import/abstract_import_flow/flow/abstract_import_flow.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/shared/utils/optional.dart';

import 'library_events.dart';

abstract class ImportEvent extends LibraryEvent {
  const ImportEvent();
}

class InitializeImport extends ImportEvent {
  const InitializeImport();

  @override
  List<Object?> get props => [];
}

class ReturnToPreviousImportScreen extends ImportEvent {
  final AbstractImportFlow importFlow;

  const ReturnToPreviousImportScreen(this.importFlow);

  @override
  List<Object?> get props => [importFlow];
}

class ChangeImportConfig extends ImportEvent {
  final Optional<Map<AbstractImportOption, bool>> checkboxSelections;
  final Optional<TagCategory> newTagCategory;
  final Optional<BaseTag?> newInitialTag;

  const ChangeImportConfig(this.checkboxSelections, this.newTagCategory, this.newInitialTag);

  @override
  List<Object?> get props => [checkboxSelections, newTagCategory, newInitialTag];
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
