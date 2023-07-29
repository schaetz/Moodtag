import 'package:moodtag/structs/imported_entities/imported_artist.dart';

class SpotifyArtist extends ImportedArtist {
  final Set<String> _tags;
  final String _spotifyId;

  SpotifyArtist(super.name, this._tags, this._spotifyId);

  Set<String> get tags => _tags;
  String get spotifyId => _spotifyId;
}
