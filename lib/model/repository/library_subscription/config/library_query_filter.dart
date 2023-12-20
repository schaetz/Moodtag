import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

class LibraryQueryFilter extends Equatable {
  final int? id;
  final String? searchItem;
  final Set<DataClass>? entityFilters;

  bool get includesAll => id == null && searchItem == null && entityFilters == null;

  const LibraryQueryFilter({this.id, this.searchItem, this.entityFilters});
  const LibraryQueryFilter.none()
      : this.id = null,
        this.searchItem = null,
        this.entityFilters = null;

  @override
  List<Object?> get props => [id, searchItem, entityFilters];
}
