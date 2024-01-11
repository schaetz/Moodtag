import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config_factory.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/events/data_loading_events.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';

import 'library_subscriber_state_mixin.dart';

/// Mixin for blocs that subscribe to the repository's library streams with all artists / tags
mixin LibraryUserBlocMixin<S extends LibrarySubscriberStateMixin> on Bloc<LibraryEvent, S> {
  Repository? _repository;

  final log = Logger('LibraryUserBlocMixin');

  /// Needs to be called in the constructor of the bloc to set up
  /// the event handlers for RequestSubscription
  void useLibrary(Repository repository) {
    this._repository = repository;
    on<RequestOrUpdateSubscription>(_handleLibrarySubscriptionRequestOrUpdate);
  }

  void _handleLibrarySubscriptionRequestOrUpdate(RequestOrUpdateSubscription event, Emitter<S> emit) async {
    await _repository?.cancelLibraryDataStream(this, event.subscriptionConfig);
    switch (event.subscriptionConfig.dataType) {
      case ArtistsList:
      case TagsList:
      case ArtistData:
      case TagData:
        await _listenToStream(event.subscriptionConfig, emit);
        break;
    }
    emit(state.updateLibrarySubscription(event.subscriptionConfig, LoadedData.loading()) as S);
  }

  Future<void> _listenToStream(SubscriptionConfig subscriptionConfig, Emitter<S> emit) async {
    log.fine('${this.runtimeType} | Start listening to subscription stream | ${subscriptionConfig.toStringVerbose()}');

    final behaviorSubject = await _repository?.getLibraryDataStream(_repository!, this, subscriptionConfig) ?? null;
    if (behaviorSubject == null) {
      log.warning(
          '${this.runtimeType} | Behavior subject could not be obtained | ${subscriptionConfig.toStringVerbose()}');
    } else {
      await emit.forEach(behaviorSubject, onData: (LoadedData loadedData) {
        log.finer(
            '${this.runtimeType} | Received library data | ${subscriptionConfig.toStringVerbose()} | ${loadedData.loadingStatus}');
        onDataReceived(subscriptionConfig, loadedData, emit);
        return state.updateLibrarySubscription(subscriptionConfig, loadedData) as S;
      }, onError: (obj, stackTrace) {
        log.warning('${this.runtimeType} | Received error | ${subscriptionConfig.toStringVerbose()}', obj, stackTrace);
        onStreamSubscriptionError(subscriptionConfig, obj, stackTrace, emit);
        return state.updateLibrarySubscription(subscriptionConfig, LoadedData.error()) as S;
      });
      log.fine('${this.runtimeType} | emit.forEach was finished | ${subscriptionConfig.toStringVerbose()}');
    }
  }

  /// Can be overridden to update the state when other datasets change
  void onDataReceived(SubscriptionConfig subscriptionConfig, LoadedData loadedData, Emitter<S> emit) {
    if (subscriptionConfig.name == SubscriptionConfigFactory.allArtistsSubscriptionName ||
        subscriptionConfig.name == SubscriptionConfigFactory.allTagsSubscriptionName) {
      state.updateLibrarySubscription(subscriptionConfig, loadedData) as S;
    }
  }

  /// Can be overridden to update the state when an error occurs in another subscription
  /// (note: this is NOT fired when LoadingStatus is ERROR, e.g. because of database errors)
  void onStreamSubscriptionError(
      SubscriptionConfig subscriptionConfig, Object object, StackTrace stackTrace, Emitter<S> emit) {
    if (subscriptionConfig.name == SubscriptionConfigFactory.allArtistsSubscriptionName ||
        subscriptionConfig.name == SubscriptionConfigFactory.allTagsSubscriptionName) {
      state.updateLibrarySubscription(subscriptionConfig, LoadedData.error()) as S;
    }
  }
}
