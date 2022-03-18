import 'package:moodtag/structs/named_entity.dart';

class ImportedArtist extends NamedEntity {
  final String _name;
  final Set<String> _genres;

  ImportedArtist(this._name, this._genres);

  String get name => _name;
  Set<String> get genres => _genres;

}