import 'package:moodtag/structs/imported_entities/import_entity.dart';

class ImportedTag extends ImportEntity {
  final String _name;
  final int? lastFmCount;
  bool _alreadyExists = false;

  ImportedTag(this._name, {this.lastFmCount});

  String get name => _name;
  bool get alreadyExists => _alreadyExists;
  void set alreadyExists(bool exists) => _alreadyExists = exists;
}
