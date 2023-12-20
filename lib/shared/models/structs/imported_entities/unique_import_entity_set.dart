import 'package:moodtag/shared/models/structs/imported_entities/import_entity.dart';
import 'package:moodtag/shared/models/structs/unique_named_entity_set.dart';

import 'imported_artist.dart';

class UniqueImportEntitySet<T extends ImportEntity> extends UniqueNamedEntitySet<T> {
  UniqueImportEntitySet() : super();
  UniqueImportEntitySet.from(Set<T> entitySet) : super.from(entitySet);

  @override
  List<T> toSortedList() {
    if (this.entitiesByName is Map<String, ImportedArtist>) {
      final List<ImportedArtist> sortedEntities = List.from(this.entitiesByName.values);
      sortedEntities.sort((a, b) => a.orderingName.compareTo(b.orderingName));
      return List<T>.from(sortedEntities);
    } else {
      return super.toSortedList();
    }
  }
}
