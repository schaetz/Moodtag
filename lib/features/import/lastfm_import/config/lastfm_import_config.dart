import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_config.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/shared/utils/optional.dart';

import 'lastfm_import_option.dart';

class LastFmImportConfig extends AbstractImportConfig<LastFmImportOption> {
  const LastFmImportConfig(
      {TagCategory? categoryForTags = null,
      BaseTag? initialTagForArtists = null,
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
      {required Optional<TagCategory> categoryForTags,
      required Optional<BaseTag?> initialTagForArtists,
      required Optional<Map<LastFmImportOption, bool>> options}) {
    return LastFmImportConfig(
        categoryForTags: categoryForTags.isPresent ? categoryForTags.content : this.categoryForTags,
        initialTagForArtists: initialTagForArtists.isPresent ? initialTagForArtists.content : this.initialTagForArtists,
        options: options.isPresent ? options.content! : this.options);
  }
}
