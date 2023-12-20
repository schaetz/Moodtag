import 'package:moodtag/shared/models/structs/imported_entities/import_entity.dart';
import 'package:moodtag/shared/utils/helpers.dart';

class ImportedArtist extends ImportEntity {
  final String _name;
  final String _orderingName;

  bool _alreadyExists = false;

  ImportedArtist(this._name) : _orderingName = getOrderingNameForArtist(_name);

  String get name => _name;
  String get orderingName => _orderingName;

  bool get alreadyExists => _alreadyExists;
  void set alreadyExists(bool exists) => _alreadyExists = exists;
}
