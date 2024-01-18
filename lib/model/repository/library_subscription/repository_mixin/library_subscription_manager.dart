import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:logging/logging.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_user_bloc_mixin.dart';
import 'package:moodtag/shared/exceptions/internal/internal_exception.dart';
import 'package:rxdart/rxdart.dart';

import '../config/subscription_config.dart';
import '../data_wrapper/loaded_data.dart';

mixin LibrarySubscriptionManager {
  final log = Logger('LibrarySubscriptionManager');

  final Map<SubscriptionConfig, Set<LibraryUserBlocMixin>> _subscriptionUsers = Map();
  final Map<SubscriptionConfig, StreamSubscription> _subscriptions = {};
  final Map<SubscriptionConfig, BehaviorSubject<LoadedData>> _loadedDataBehaviorSubjects = {};

  Future<BehaviorSubject<LoadedData>?> getLibraryDataStream(
      Repository repository, LibraryUserBlocMixin userBloc, SubscriptionConfig subscriptionConfig) async {
    if (_loadedDataBehaviorSubjects.containsKey(subscriptionConfig)) {
      return _loadedDataBehaviorSubjects[subscriptionConfig];
    }

    Stream Function() streamReference = _getRepositoryStream(subscriptionConfig, repository);
    final createdBehaviorSubject = await _setupStreamSubscription(subscriptionConfig, streamReference);
    _addSubscription(userBloc, subscriptionConfig, createdBehaviorSubject);
    return createdBehaviorSubject;
  }

  void _addSubscription(LibraryUserBlocMixin userBloc, SubscriptionConfig subscriptionConfig,
      BehaviorSubject<LoadedData> createdBehaviorSubject) {
    _loadedDataBehaviorSubjects.putIfAbsent(subscriptionConfig, () => createdBehaviorSubject);

    final Set<LibraryUserBlocMixin> currentUserBlocs =
        _subscriptionUsers.containsKey(subscriptionConfig) ? _subscriptionUsers[subscriptionConfig]! : {};
    _subscriptionUsers.putIfAbsent(subscriptionConfig, () => currentUserBlocs..add(userBloc));
  }

  Future<void> cancelLibraryDataStream(LibraryUserBlocMixin userBloc, SubscriptionConfig subscriptionConfig) async {
    _subscriptionUsers[subscriptionConfig]?.remove(userBloc);

    if (_subscriptionUsers[subscriptionConfig] == null || _subscriptionUsers[subscriptionConfig]!.isEmpty) {
      await _loadedDataBehaviorSubjects[subscriptionConfig]?.close();
      _loadedDataBehaviorSubjects.remove(subscriptionConfig);

      await _subscriptions[subscriptionConfig]?.cancel();
      _subscriptions.remove(subscriptionConfig);

      _subscriptionUsers.remove(subscriptionConfig);
    }
  }

  void cancelAllStreamSubscriptions() async {
    _subscriptionUsers.clear();
    _loadedDataBehaviorSubjects.clear();
    _subscriptions.values.forEach((streamSubscription) => streamSubscription.cancel());
    _subscriptions.clear();
  }

  Stream Function() _getRepositoryStream(SubscriptionConfig subscriptionConfig, Repository repository) {
    switch (subscriptionConfig.dataType) {
      case ArtistsList:
        Set<Tag> filterTags = _getSetOfFilterEntities<Tag>(subscriptionConfig.filter.entityFilters);
        return () => repository.getArtistsDataList(
            filterTagIds: filterTags.map((tag) => tag.id).toSet(), searchItem: subscriptionConfig.filter.searchItem);
      case TagsList:
        if (subscriptionConfig.filter.entityFilters != null) {
          log.warning('Cannot apply entity filters to TagsList subscription');
          throw InternalException('Cannot apply entity filters to TagsList subscription');
        }
        return () => repository.getTagsDataList(searchItem: subscriptionConfig.filter.searchItem);
      case TagCategoriesList:
        if (!subscriptionConfig.filter.includesAll) {
          log.warning('Cannot apply filters to TagCategoriesList subscription');
          throw InternalException('Cannot apply filters to TagCategoriesList subscription');
        }
        return () => repository.getTagCategories();
      case ArtistData:
        if (subscriptionConfig.filter.searchId == null) {
          log.warning('No artist Id supplied for ArtistData subscription');
          throw InternalException('No artist Id supplied for ArtistData subscription');
        } else if (subscriptionConfig.filter.entityFilters != null) {
          log.warning('Cannot apply entity filters to ArtistData subscription');
          throw InternalException('Cannot apply entity filters to ArtistData subscription');
        }
        return () => repository.getArtistDataById(subscriptionConfig.filter.searchId!);
      case TagData:
        if (subscriptionConfig.filter.searchId == null) {
          log.warning('No tag Id supplied for TagData subscription');
          throw InternalException('No tag Id supplied for Tag subscription');
        } else if (subscriptionConfig.filter.entityFilters != null) {
          log.warning('Cannot apply entity filters to TagData subscription');
          throw InternalException('Cannot apply entity filters to Tag subscription');
        }
        return () => repository.getTagDataById(subscriptionConfig.filter.searchId!);
      default:
        log.warning('Unknown data type for stream subscription: ${subscriptionConfig.dataType}');
        throw InternalException('Unknown data type for stream subscription: ${subscriptionConfig.dataType}');
    }
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

  Future<BehaviorSubject<LoadedData>> _setupStreamSubscription(
      SubscriptionConfig subscriptionConfig, Stream Function() streamReference) async {
    log.fine('LibrarySubscriptionManager | Setup stream subscription | ${subscriptionConfig.toStringVerbose()}');

    final behaviorSubject = BehaviorSubject<LoadedData>();
    behaviorSubject.add(LoadedData.loading());

    final streamSubscription = await streamReference().handleError((errorObject) {
      log.warning('Update BehaviorSubject with error from stream for $subscriptionConfig: ', errorObject);
      final errorMessage =
          errorObject is String ? errorObject : (errorObject is SqliteException ? errorObject.message : null);
      behaviorSubject.add(LoadedData.error(message: errorMessage));
    }).listen((dataFromStream) {
      log.finer('Update BehaviorSubject for ${subscriptionConfig.toString()}');
      behaviorSubject.add(LoadedData.success(dataFromStream));
    });
    _subscriptions.putIfAbsent(subscriptionConfig, () => streamSubscription);

    return behaviorSubject;
  }
}
