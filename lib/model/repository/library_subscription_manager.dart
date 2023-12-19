import 'dart:async';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:moodtag/exceptions/internal/internal_exception.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

import 'loaded_data.dart';
import 'subscription_config.dart';

mixin LibrarySubscriptionManager {
  final log = Logger('LibrarySubscriptionManager');

  final Map<SubscriptionConfig, StreamSubscription> _subscriptions = {};

  Future<BehaviorSubject<LoadedData>?> getLibraryDataStream(
      Repository repository, SubscriptionConfig subscriptionConfig) async {
    Stream Function() streamReference;
    switch (subscriptionConfig.dataType) {
      case ArtistsList:
        Set<Tag> filterTags = _getSetOfFilterEntities<Tag>(subscriptionConfig.filter.entityFilters);
        streamReference = () =>
            repository.getArtistsDataList(filterTags: filterTags, searchItem: subscriptionConfig.filter.searchItem);
        break;
      case TagsList:
        if (subscriptionConfig.filter.entityFilters != null) {
          log.warning('Cannot apply entity filters to TagsList subscription');
          throw InternalException('Cannot apply entity filters to TagsList subscription');
        }
        streamReference = () => repository.getTagsDataList(searchItem: subscriptionConfig.filter.searchItem);
        break;
      case ArtistData:
        if (subscriptionConfig.filter.id == null) {
          log.warning('No artist Id supplied for ArtistData subscription');
          throw InternalException('No artist Id supplied for ArtistData subscription');
        } else if (subscriptionConfig.filter.entityFilters != null) {
          log.warning('Cannot apply entity filters to ArtistData subscription');
          throw InternalException('Cannot apply entity filters to ArtistData subscription');
        }
        streamReference = () => repository.getArtistDataById(subscriptionConfig.filter.id!);
        break;
      case TagData:
        if (subscriptionConfig.filter.id == null) {
          log.warning('No tag Id supplied for TagData subscription');
          throw InternalException('No tag Id supplied for Tag subscription');
        } else if (subscriptionConfig.filter.entityFilters != null) {
          log.warning('Cannot apply entity filters to TagData subscription');
          throw InternalException('Cannot apply entity filters to Tag subscription');
        }
        streamReference = () => repository.getTagDataById(subscriptionConfig.filter.id!);
        break;
      default:
        log.warning('Unknown data type for stream subscription: ${subscriptionConfig.dataType}');
        throw InternalException('Unknown data type for stream subscription: ${subscriptionConfig.dataType}');
    }
    return await setupStreamSubscription(subscriptionConfig, streamReference);
  }

  Set<T> _getSetOfFilterEntities<T extends DataClass>(Set<DataClass>? entityFilters) {
    if (entityFilters != null && entityFilters.isNotEmpty) {
      try {
        return Set<T>.from(entityFilters);
      } catch (e) {
        throw InternalException('Invalid type for set of filter entities: $entityFilters');
      }
    }
    return {};
  }

  Future<BehaviorSubject<LoadedData>> setupStreamSubscription(
      SubscriptionConfig subscriptionConfig, Stream Function() streamReference) async {
    log.fine('Setup $subscriptionConfig');

    final behaviorSubject = BehaviorSubject<LoadedData>();
    behaviorSubject.add(LoadedData.loading());

    final streamSubscription = await streamReference().handleError((errorMessage) {
      log.warning('Update BehaviorSubject with error from stream for $subscriptionConfig: ', errorMessage);
      behaviorSubject.add(LoadedData.error(message: errorMessage));
    }).listen((dataFromStream) {
      log.finer('Update BehaviorSubject for $subscriptionConfig');
      behaviorSubject.add(LoadedData.success(dataFromStream));
    });
    _subscriptions.putIfAbsent(subscriptionConfig, () => streamSubscription);

    return behaviorSubject;
  }

  Future<void> cancelStreamSubscription(SubscriptionConfig subscriptionConfig) async {
    return await _subscriptions[subscriptionConfig]?.cancel();
  }

  void cancelAllStreamSubscriptions() async {
    _subscriptions.values.forEach((streamSubscription) => streamSubscription.cancel());
  }
}
