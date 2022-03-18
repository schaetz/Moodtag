import 'package:moodtag/structs/named_entity.dart';

class ImportedGenre extends NamedEntity {
  final String _name;

  ImportedGenre(this._name);

  String get name => _name;
}