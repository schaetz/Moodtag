import 'package:equatable/equatable.dart';

import 'library_query_filter.dart';

/// Configuration for a subscription to a library data stream;
/// Existing streams will be reused based on equality of the respective subscription configs (name and configuration)
class SubscriptionConfig extends Equatable {
  // immutable subscriptions will never be renewed because of a changed filter; allArtists / allTags are immutable
  final bool isImmutable;
  final String? name;
  final Type dataType;
  final LibraryQueryFilter filter;

  const SubscriptionConfig(this.dataType,
      {this.isImmutable = false, this.name = null, this.filter = const LibraryQueryFilter.none()});

  const SubscriptionConfig.immutable(this.name, this.dataType, {this.filter = const LibraryQueryFilter.none()})
      : this.isImmutable = true;

  @override
  List<Object?> get props => [isImmutable, name, dataType, filter];

  @override
  String toString() {
    if (name != null) {
      return '[$name]';
    } else if (filter.includesAll) {
      return '[$dataType ALL]';
    } else {
      return '[$dataType filtered]';
    }
  }

  String toStringVerbose() {
    final dataTypeString = 'dataType: $dataType';
    String filterString = filter.includesAll ? 'ALL' : filter.getQueryFilterString();
    return '[$dataTypeString; $filterString]';
  }
}
