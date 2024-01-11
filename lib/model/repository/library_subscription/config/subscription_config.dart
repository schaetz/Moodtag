import 'package:equatable/equatable.dart';
import 'package:equatable/src/equatable_utils.dart';

import 'library_query_filter.dart';

/// Configuration for a subscription to a library data stream;
/// configurations with changing filters should be named to associate them correctly
class SubscriptionConfig extends Equatable {
  final bool isUnique;
  final String? name;
  final Type dataType;
  final LibraryQueryFilter filter;

  const SubscriptionConfig(this.dataType,
      {this.isUnique = false, this.name = null, this.filter = const LibraryQueryFilter.none()});

  const SubscriptionConfig.notUnique(this.dataType, {this.name = null, this.filter = const LibraryQueryFilter.none()})
      : this.isUnique = false;

  const SubscriptionConfig.unique(this.name, this.dataType, {this.filter = const LibraryQueryFilter.none()})
      : this.isUnique = true;

  @override
  List<Object?> get props => [isUnique, name, dataType, filter];

  // If the subscription is declared as unique, the equality of name signifies equality of subscription
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionConfig && ((isUnique && name != null && name == other.name) || equals(props, other.props));

  @override
  int get hashCode => isUnique && name != null
      ? runtimeType.hashCode ^ mapPropsToHashCode([isUnique, name])
      : runtimeType.hashCode ^ mapPropsToHashCode(props);

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
