import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_period.dart';

import 'imported_artist.dart';

class LastFmArtist extends ImportedArtist {
  late final Map<LastFmImportPeriod, int> _playCounts;

  LastFmArtist.withSinglePlayCount(super.name, LastFmImportPeriod period, int overallPlayCount) {
    this._playCounts = {period: overallPlayCount};
  }

  Map<LastFmImportPeriod, int> get playCounts => _playCounts;
}
