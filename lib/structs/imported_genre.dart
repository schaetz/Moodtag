import 'package:moodtag/structs/import_entity.dart';

class ImportedGenre extends ImportEntity {
  final String _name;
  bool _alreadyExists = false;

  ImportedGenre(this._name);

  String get name => _name;
  bool get alreadyExists => _alreadyExists;
  void set alreadyExists(bool exists) => _alreadyExists = exists;
}
