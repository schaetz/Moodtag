import 'package:moodtag/structs/imported_entities/imported_artist.dart';

class LastFmArtist extends ImportedArtist {
  final int _playCount;

  LastFmArtist(super.name, this._playCount);

  int get playCount => _playCount;
}
