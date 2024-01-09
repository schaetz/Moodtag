import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/data_class_extension.dart';

class LibraryQueryFilter extends Equatable {
  final int? id;
  final String searchItem;
  final Set<DataClass>? entityFilters;

  bool get includesAll => id == null && searchItem.isEmpty && (entityFilters == null || entityFilters!.isEmpty);

  const LibraryQueryFilter({this.id, this.searchItem = '', this.entityFilters});
  const LibraryQueryFilter.none()
      : this.id = null,
        this.searchItem = '',
        this.entityFilters = null;

  @override
  List<Object?> get props => [id, searchItem, entityFilters];

  String getQueryFilterString() {
    final idString = (id == null) ? null : 'id: $id';
    final searchItemString = searchItem.isEmpty ? null : 'searchItem: ${searchItem}';

    final entityFiltersString = (entityFilters == null || entityFilters!.isEmpty)
        ? null
        : 'entities: (' + entityFilters!.map((DataClass dataObject) => dataObject.getName()).join(',') + ')';

    if (idString == null && searchItemString == null && entityFiltersString == null) {
      return 'null';
    }

    return [idString, searchItemString, entityFiltersString].where((element) => element != null).join('; ');
  }
}
