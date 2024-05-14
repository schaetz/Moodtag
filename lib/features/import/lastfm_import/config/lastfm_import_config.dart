import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_config.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

import 'lastfm_import_option.dart';

class LastFmImportConfig extends AbstractImportConfig {
  final TagCategory? _categoryForTags;
  final Tag? _initialTagForArtists;
  final Map<LastFmImportOption, bool> options;

  const LastFmImportConfig(
      {TagCategory? categoryForTagsVal = null, Tag? initialTagForArtistsVal = null, this.options = const {}})
      : _categoryForTags = categoryForTagsVal,
        _initialTagForArtists = initialTagForArtistsVal,
        super();

  @override
  TagCategory? get categoryForTags => _categoryForTags;

  @override
  Tag? get initialTagForArtists => _initialTagForArtists;

  bool get isValid =>
      _categoryForTags != null &&
      (options[LastFmImportOption.allTimeTopArtists] == true ||
          options[LastFmImportOption.lastMonthTopArtists] == true);

  @override
  List<Object?> get props => [_categoryForTags, _initialTagForArtists, options];

  LastFmImportConfig copyWith(
      {TagCategory? categoryForTags, Tag? initialTagForArtists, Map<LastFmImportOption, bool>? options}) {
    return LastFmImportConfig(
        categoryForTagsVal: categoryForTags ?? this._categoryForTags,
        initialTagForArtistsVal: initialTagForArtists ?? this._initialTagForArtists,
        options: options ?? this.options);
  }
}
