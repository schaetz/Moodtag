import 'package:moodtag/structs/import_entity.dart';

class ImportedArtist extends ImportEntity {
  final String _name;
  final Set<String> _genres;
  final String _spotifyId;
  bool _alreadyExists = false;

  ImportedArtist(this._name, this._genres, this._spotifyId);

  String get name => _name;
  Set<String> get genres => _genres;
  String get spotifyId => _spotifyId;

  bool get alreadyExists => _alreadyExists;
  void set alreadyExists(bool exists) => _alreadyExists = exists;
}
