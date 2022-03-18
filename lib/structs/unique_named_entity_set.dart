/*
 * Defines a set of named entities with unique identifiers that can be passed
 * as an argument to a SelectionList
 */
import 'package:moodtag/structs/named_entity.dart';

class UniqueNamedEntitySet<T extends NamedEntity> {

  Map<String,T> _entitiesByName;

  UniqueNamedEntitySet() : _entitiesByName = {};

  UniqueNamedEntitySet.from(Set<T> entitySet) {
    Map<String,T> initialMap = {};
    for (T entity in entitySet) {
      initialMap.putIfAbsent(entity.name, () => entity);
    }
    this._entitiesByName = initialMap;
  }


  bool get isEmpty => _entitiesByName.isEmpty;

  Set<T> get values => Set.from(_entitiesByName.values);

  void add(T newEntity) {
    _entitiesByName.putIfAbsent(newEntity.name, () => newEntity);
  }

  void addAll(UniqueNamedEntitySet<T> otherSet) {
    for (T entity in otherSet.values) {
      add(entity);
    }
  }

}