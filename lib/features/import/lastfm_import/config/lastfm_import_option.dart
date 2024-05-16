import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_option.dart';

enum LastFmImportOption implements AbstractImportOption {
  allTimeTopArtists('All-time top artists'),
  lastMonthTopArtists('Last month\'s top artists');

  final String caption;
  const LastFmImportOption(this.caption);
}
