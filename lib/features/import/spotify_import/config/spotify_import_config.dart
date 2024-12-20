import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_config.dart';
import 'package:moodtag/features/import/spotify_import/config/spotify_import_option.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/shared/utils/optional.dart';

class SpotifyImportConfig extends AbstractImportConfig<SpotifyImportOption> {
  const SpotifyImportConfig(
      {TagCategory? categoryForTags = null,
      BaseTag? initialTagForArtists = null,
      Map<SpotifyImportOption, bool> options = const {}})
      : super(categoryForTags, initialTagForArtists, options);

  @override
  bool get isValid =>
      categoryForTags != null &&
      (options[SpotifyImportOption.topArtists] == true || options[SpotifyImportOption.followedArtists] == true);

  bool get doImportGenres => options[SpotifyImportOption.artistGenres] == true;

  @override
  List<Object?> get props => [categoryForTags, initialTagForArtists, options];

  SpotifyImportConfig copyWith(
      {required Optional<TagCategory?> categoryForTags,
      required Optional<BaseTag?> initialTagForArtists,
      required Optional<Map<SpotifyImportOption, bool>> options}) {
    return SpotifyImportConfig(
        categoryForTags: categoryForTags.isPresent ? categoryForTags.content : this.categoryForTags,
        initialTagForArtists: initialTagForArtists.isPresent ? initialTagForArtists.content : this.initialTagForArtists,
        options: options.isPresent ? options.content! : this.options);
  }
}
