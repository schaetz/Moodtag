import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/library_query_filter.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/subscription_config.dart';

abstract class DataLoadingEvent extends LibraryEvent {
  const DataLoadingEvent();
}

class RequestOrUpdateSubscription extends DataLoadingEvent {
  final SubscriptionConfig subscriptionConfig;

  RequestOrUpdateSubscription(Type dataType,
      {String? name, LibraryQueryFilter filter = const LibraryQueryFilter.none()})
      : this.subscriptionConfig = SubscriptionConfig(dataType, name: name, filter: filter);

  const RequestOrUpdateSubscription.withConfig(this.subscriptionConfig);

  @override
  List<Object?> get props => [subscriptionConfig];
}

class StartedLoading<T> extends DataLoadingEvent {
  @override
  List<Object?> get props => [];
}

class DataUpdated<T> extends DataLoadingEvent {
  final T? data;
  final Object? error;

  const DataUpdated({this.data, this.error});

  @override
  List<Object?> get props => [data, error];
}

class AllArtistsUpdated extends DataUpdated<LoadedData<ArtistsList>> {
  const AllArtistsUpdated({LoadedData<ArtistsList>? data, Object? error}) : super(data: data, error: error);
}

class AllTagsUpdated extends DataUpdated<LoadedData<TagsList>> {
  const AllTagsUpdated({LoadedData<TagsList>? data, Object? error}) : super(data: data, error: error);
}
