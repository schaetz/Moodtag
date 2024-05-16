import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_option.dart';

enum SpotifyImportOption implements AbstractImportOption {
  topArtists('Top artists'),
  followedArtists('Followed artists'),
  artistGenres('Artist genres');

  final String caption;
  const SpotifyImportOption(this.caption);
}
