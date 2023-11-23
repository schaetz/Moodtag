/*
 * Defines a set of named entities with unique identifiers that can be passed
 * as an argument to a SelectionList
 */
import 'package:moodtag/structs/named_entity.dart';

class UniqueNamedEntitySet<T extends NamedEntity> {
  late final Map<String, T> _entitiesByName;

  UniqueNamedEntitySet() : _entitiesByName = {};

  UniqueNamedEntitySet.from(Set<T> entitySet) {
    Map<String, T> initialMap = {};
    for (T entity in entitySet) {
      initialMap.putIfAbsent(entity.name, () => entity);
    }
    this._entitiesByName = initialMap;
  }

  Map<String, T> get entitiesByName => _entitiesByName;
  bool get isEmpty => _entitiesByName.isEmpty;

  Set<T> get values => Set.from(_entitiesByName.values);

  void add(T newEntity) {
    _entitiesByName.putIfAbsent(newEntity.name, () => newEntity);
  }

  void addOrUpdate(T updateEntity, T Function(T, T) updateFunction) {
    _entitiesByName.update(updateEntity.name, (existingEntity) => updateFunction(existingEntity, updateEntity),
        ifAbsent: () => updateEntity);
  }

  void addAll(UniqueNamedEntitySet<T> otherSet) {
    for (T entity in otherSet.values) {
      add(entity);
    }
  }

  void addOrUpdateAll(UniqueNamedEntitySet<T> otherSet, T Function(T, T) updateFunction) {
    for (T entity in otherSet.values) {
      addOrUpdate(entity, updateFunction);
    }
  }

  List<T> toSortedList() {
    final List<T> sortedEntities = List.from(_entitiesByName.values);
    sortedEntities.sort((a, b) => a.name.compareTo(b.name));
    return sortedEntities;
  }
}
