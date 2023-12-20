import 'package:equatable/equatable.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/subscription_config.dart';

/// Property of Bloc states for blocs that are subscribed to the library;
/// holds the subscriptions to library entity streams
class LibrarySubscriptionSubState extends Equatable {
  final Map<SubscriptionConfig, LoadedData> subscriptions;

  const LibrarySubscriptionSubState({this.subscriptions = const {}});

  @override
  List<Object?> get props => [subscriptions];

  LibrarySubscriptionSubState update(SubscriptionConfig subscriptionConfig, LoadedData loadedData) {
    final newSubscriptions = Map<SubscriptionConfig, LoadedData>.from(subscriptions);
    newSubscriptions[subscriptionConfig] = loadedData;
    return LibrarySubscriptionSubState(subscriptions: newSubscriptions);
  }
}
