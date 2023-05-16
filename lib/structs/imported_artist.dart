import 'package:moodtag/structs/import_entity.dart';

class ImportedArtist extends ImportEntity {
  final String _name;
  final Set<String> _genres;
  bool _alreadyExists = false;

  ImportedArtist(this._name, this._genres);

  String get name => _name;
  Set<String> get genres => _genres;
  bool get alreadyExists => _alreadyExists;
  void set alreadyExists(bool exists) => _alreadyExists = exists;
}
