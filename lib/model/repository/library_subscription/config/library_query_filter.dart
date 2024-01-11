import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:moodtag/model/database/data_class_extension.dart';

class LibraryQueryFilter extends Equatable {
  final int? searchId;
  final String searchItem;
  final Set<DataClass>? entityFilters;

  bool get includesAll => searchId == null && searchItem.isEmpty && (entityFilters == null || entityFilters!.isEmpty);

  const LibraryQueryFilter({this.searchId, this.searchItem = '', this.entityFilters});
  const LibraryQueryFilter.none()
      : this.searchId = null,
        this.searchItem = '',
        this.entityFilters = null;

  @override
  List<Object?> get props => [searchId, searchItem, entityFilters];

  String getQueryFilterString() {
    final idString = (searchId == null) ? null : 'searchId: $searchId';
    final searchItemString = searchItem.isEmpty ? null : 'searchItem: ${searchItem}';

    final entityFiltersString = (entityFilters == null || entityFilters!.isEmpty)
        ? null
        : 'entities: (' + entityFilters!.map((DataClass dataObject) => dataObject.getName()).join(',') + ')';

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
