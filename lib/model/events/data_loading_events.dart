import 'package:moodtag/model/events/library_events.dart';

abstract class DataLoadingEvent extends LibraryEvent {
  const DataLoadingEvent();
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
