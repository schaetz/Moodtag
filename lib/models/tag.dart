import 'abstract_entity.dart';

class Tag extends AbstractEntity {

  static const denotationSingular = 'tag';
  static const denotationPlural = 'tags';

  int id;
  String name;

  Tag(this.name);

}