import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:moodtag/model/entities/entities.dart';

class LibraryQueryFilter extends Equatable {
  final int? searchId;
  final String? searchItem;
  final Set<LibraryEntity>? entityFilters;

  bool get includesAll => searchId == null && searchItem == null && (entityFilters == null || entityFilters!.isEmpty);

  const LibraryQueryFilter({this.searchId, this.searchItem = '', this.entityFilters});
  const LibraryQueryFilter.none()
      : this.searchId = null,
        this.searchItem = null,
        this.entityFilters = null;

  @override
  List<Object?> get props => [searchId, searchItem, entityFilters];

  String getQueryFilterString() {
    final idString = (searchId == null) ? null : 'searchId: $searchId';
    final searchItemString = (searchItem == null) ? null : 'searchItem: "${searchItem}"';

    final entityFiltersString = (entityFilters == null || entityFilters!.isEmpty)
        ? null
        : 'entities: (' + entityFilters!.map((LibraryEntity entity) => entity.name).join(',') + ')';

    if (idString == null && searchItemString == null && entityFiltersString == null) {
      return 'null';
    }

    return [idString, searchItemString, entityFiltersString].where((element) => element != null).join('; ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryQueryFilter &&
          searchId == other.searchId &&
          searchItem == other.searchItem &&
          setEquals(entityFilters, other.entityFilters);
}
