import 'package:moodtag/structs/imported_artist.dart';

class ImportedArtistsSet {

  Map<String,ImportedArtist> _importArtistsByName;

  ImportedArtistsSet() : _importArtistsByName = {};

  ImportedArtistsSet.from(Set<ImportedArtist> importedArtists) {
    Map<String,ImportedArtist> initialMap = {};
    for (ImportedArtist artist in importedArtists) {
      initialMap.putIfAbsent(artist.name, () => artist);
    }
    this._importArtistsByName = initialMap;
  }


  bool get isEmpty => _importArtistsByName.isEmpty;

  Set<ImportedArtist> get artists => Set.from(_importArtistsByName.values);

  void addArtist(ImportedArtist newArtist) {
    _importArtistsByName.putIfAbsent(newArtist.name, () => newArtist);
  }

  void addAll(ImportedArtistsSet otherSet) {
    for (ImportedArtist artist in otherSet.artists) {
      addArtist(artist);
    }
  }

}