import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_config.dart';
import 'package:moodtag/model/entities/entities.dart';

import 'lastfm_import_option.dart';

class LastFmImportConfig extends AbstractImportConfig<LastFmImportOption> {
  const LastFmImportConfig(
      {TagCategory? categoryForTags = null,
      Tag? initialTagForArtists = null,
      Map<LastFmImportOption, bool> options = const {}})
      : super(categoryForTags, initialTagForArtists, options);

  @override
  bool get isValid =>
      categoryForTags != null &&
      (options[LastFmImportOption.allTimeTopArtists] == true ||
          options[LastFmImportOption.lastMonthTopArtists] == true);

  @override
  List<Object?> get props => [categoryForTags, initialTagForArtists, options];

  LastFmImportConfig copyWith(
      {TagCategory? categoryForTags, Tag? initialTagForArtists, Map<LastFmImportOption, bool>? options}) {
    return LastFmImportConfig(
        categoryForTags: categoryForTags ?? this.categoryForTags,
        initialTagForArtists: initialTagForArtists ?? this.initialTagForArtists,
        options: options ?? this.options);
  }
}
