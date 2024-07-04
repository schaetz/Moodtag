import 'package:equatable/equatable.dart';
import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_option.dart';
import 'package:moodtag/model/entities/entities.dart';

abstract class AbstractImportConfig<O extends AbstractImportOption> extends Equatable {
  final TagCategory? _categoryForTags;
  final BaseTag? _initialTagForArtists;
  final Map<O, bool> _options;

  const AbstractImportConfig(this._categoryForTags, this._initialTagForArtists, this._options);

  TagCategory? get categoryForTags => _categoryForTags;

  BaseTag? get initialTagForArtists => _initialTagForArtists;

  Map<O, bool> get options => _options;

  bool get isValid;
}
