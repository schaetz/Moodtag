import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/model/repository/subscription_config.dart';

import 'library_subscriber_state_mixin.dart';

/// Mixin for blocs that subscribe to the repository's library streams with all artists / tags
mixin LibraryUserBlocMixin<S extends LibrarySubscriberStateMixin> on Bloc<LibraryEvent, S> {
  Repository? _repository;

  final log = Logger('LibraryUserBlocMixin');

  /// Needs to be called in the constructor of the bloc to set up
  /// the event handlers for RequestSubscription
  void useLibrary(Repository repository) {
    this._repository = repository;
    on<RequestSubscription>(_handleLibrarySubscriptionRequested);
    on<UpdateSubscriptionFilter>(_handleUpdateSubscriptionFilter);
  }

  void _handleLibrarySubscriptionRequested(RequestSubscription event, Emitter<S> emit) async {
    emit(state.updateLibrarySubscription(event.subscriptionConfig, LoadedData.loading()) as S);
    await _repository?.cancelStreamSubscription(event.subscriptionConfig);
    switch (event.subscriptionConfig.dataType) {
      case ArtistsList:
        _listenToStream(event.subscriptionConfig, emit);
        break;
      case TagsList:
        _listenToStream(event.subscriptionConfig, emit);
        break;
      case ArtistData:
        _listenToStream(event.subscriptionConfig, emit);
        break;
      case TagData:
        _listenToStream(event.subscriptionConfig, emit);
        break;
    }
  }

  // TODO Remove code duplication
  void _handleUpdateSubscriptionFilter(UpdateSubscriptionFilter event, Emitter<S> emit) async {
    emit(state.updateLibrarySubscription(event.subscriptionConfig, LoadedData.loading()) as S);
    await _repository?.cancelStreamSubscription(event.subscriptionConfig);
    _listenToStream(event.subscriptionConfig, emit);
  }

  void _listenToStream(SubscriptionConfig subscriptionConfig, Emitter<S> emit) async {
    log.fine('Start listening to stream for $subscriptionConfig');

    final behaviorSubject = await _repository?.getLibraryDataStream(subscriptionConfig) ?? null;
    if (behaviorSubject != null) {
      await emit.forEach<LoadedData>(behaviorSubject, onData: (loadedData) {
        log.finer('Bloc received library data for $subscriptionConfig', loadedData);
        onDataReceived(subscriptionConfig, loadedData, emit);
        return state.updateLibrarySubscription(subscriptionConfig, loadedData) as S;
      }, onError: (obj, stackTrace) {
        log.warning('Received error for $subscriptionConfig', obj, stackTrace);
        onStreamSubscriptionError(subscriptionConfig, obj, stackTrace, emit);
        return state.updateLibrarySubscription(subscriptionConfig, LoadedData.error()) as S;
      });
    }
  }

  /// Can be overridden to run additional logic when a new instance of the dataset is loaded
  void onDataReceived(SubscriptionConfig subscriptionConfig, LoadedData loadedData, Emitter<S> emit) => ();

  /// Can be overridden to run additional logic when a subscription error occurs
  /// (note: this is NOT fired when LoadingStatus is ERROR, e.g. because of database errors)
  void onStreamSubscriptionError(
          SubscriptionConfig subscriptionConfig, Object object, StackTrace stackTrace, Emitter<S> emit) =>
      ();
}
