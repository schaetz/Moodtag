import 'package:moodtag/structs/imported_entities/import_entity.dart';

class ImportedArtist extends ImportEntity {
  final String _name;

  bool _alreadyExists = false;

  ImportedArtist(this._name);

  String get name => _name;

  bool get alreadyExists => _alreadyExists;
  void set alreadyExists(bool exists) => _alreadyExists = exists;
}
