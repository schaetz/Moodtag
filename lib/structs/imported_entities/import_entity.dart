import 'package:moodtag/structs/named_entity.dart';

abstract class ImportEntity extends NamedEntity {
  bool get alreadyExists;
  void set alreadyExists(bool exists);
}
