import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/data_loading_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/repository.dart';

import 'library_subscriber_state_mixin.dart';

/// Mixin for blocs that subscribe to the repository's library streams with all artists / tags
mixin LibraryUserBlocMixin<S extends LibrarySubscriberStateMixin> on Bloc<LibraryEvent, S> {
  Repository? _repository;

  /// Needs to be called in the constructor of the bloc to set up
  /// the event handlers for RequestSubscription
  void useLibrary(Repository repository) {
    this._repository = repository;
    on<RequestSubscription<ArtistsList>>(_handleLibrarySubscriptionRequested<ArtistsList>);
    on<RequestSubscription<TagsList>>(_handleLibrarySubscriptionRequested<TagsList>);
  }

  void _handleLibrarySubscriptionRequested<T extends List<DataClassWithEntityName>>(
      RequestSubscription event, Emitter<S> emit) async {
    emit(state.updateLibrarySubscription<T>(LoadedData.loading()) as S);

    final behaviorSubject = _repository?.getLibraryDataStream<T>() ?? null;
    if (behaviorSubject != null) {
      await emit.forEach<LoadedData<T>>(
        behaviorSubject,
        onData: (loadedData) => _onDataReceived(loadedData),
        onError: (obj, stackTrace) => _onStreamSubscriptionError(obj, stackTrace),
      );
    }
  }

  /// Can be overridden to run additional logic when a new instance of the dataset is loaded
  S _onDataReceived<T extends List<DataClassWithEntityName>>(LoadedData<T> loadedData) =>
      state.updateLibrarySubscription<T>(loadedData) as S;

  /// Can be overridden to run additional logic when a subscription error occurrs
  /// (note: this is NOT fired when LoadingStatus is ERROR, e.g. because of database errors)
  S _onStreamSubscriptionError<T extends List<DataClassWithEntityName>>(Object object, StackTrace stackTrace) =>
      state.updateLibrarySubscription<T>(LoadedData.error()) as S;
}
