import 'package:equatable/equatable.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';

/// Property of Bloc states for blocs that are subscribed to the library;
/// holds the subscriptions to library entity streams
class LibrarySubscriptionSubState extends Equatable {
  final Map<SubscriptionConfig, LoadedData> _subscriptionsWithCurrentData;

  LoadedData? getCurrentDataForSubscription(SubscriptionConfig subscriptionConfig) =>
      _subscriptionsWithCurrentData[subscriptionConfig];

  const LibrarySubscriptionSubState(
      {Map<SubscriptionConfig, LoadedData<dynamic>> subscriptionsWithCurrentData = const {}})
      : _subscriptionsWithCurrentData = subscriptionsWithCurrentData;

  @override
  List<Object?> get props => [_subscriptionsWithCurrentData];

  LibrarySubscriptionSubState update(SubscriptionConfig subscriptionConfig, LoadedData loadedData) {
    final newSubscriptionsMap = Map<SubscriptionConfig, LoadedData>.from(_subscriptionsWithCurrentData);
    newSubscriptionsMap[subscriptionConfig] = loadedData;
    return LibrarySubscriptionSubState(subscriptionsWithCurrentData: newSubscriptionsMap);
  }
}
