import 'package:equatable/equatable.dart';
import 'package:equatable/src/equatable_utils.dart';

import 'library_query_filter.dart';

/// Configuration for a subscription to a library data stream;
/// configurations with changing filters should be named to associate them correctly
class SubscriptionConfig extends Equatable {
  final String? name;
  final Type dataType;
  final LibraryQueryFilter filter;

  const SubscriptionConfig(this.dataType, {this.name = null, this.filter = const LibraryQueryFilter.none()});

  const SubscriptionConfig.named(this.name, this.dataType, {this.filter = const LibraryQueryFilter.none()});

  @override
  List<Object?> get props => [name, dataType, filter];

  // If the subscription is named, the equality of name signifies equality of subscription
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equatable &&
          runtimeType == other.runtimeType &&
          ((name != null && name == (other as SubscriptionConfig).name) ||
              (name == null && equals(props, other.props)));

  @override
  int get hashCode => name != null
      ? runtimeType.hashCode ^ mapPropsToHashCode([name])
      : runtimeType.hashCode ^ mapPropsToHashCode(props);

  @override
  String toString() {
    if (name != null) {
      return '$name subscription';
    } else if (filter.includesAll) {
      return '$dataType [ALL] subscription';
    } else {
      return '$dataType [filtered] subscription';
    }
  }
}
