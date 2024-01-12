import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/models/structs/imported_entities/import_entity.dart';

class ImportedTag extends ImportEntity {
  final String _name;
  final TagCategory category;
  final Tag? parentTag;
  final int? lastFmCount;
  bool _alreadyExists = false;

  ImportedTag(this._name, {required this.category, this.parentTag, this.lastFmCount});

  String get name => _name;
  bool get alreadyExists => _alreadyExists;
  void set alreadyExists(bool exists) => _alreadyExists = exists;
}
