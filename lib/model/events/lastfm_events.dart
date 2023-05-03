import 'library_events.dart';

abstract class LastFmEvent extends LibraryEvent {
  const LastFmEvent();
}

class LastFmAccountUpdated extends LastFmEvent {
  final String? accountName;
  final Object? error;

  const LastFmAccountUpdated({this.accountName, this.error});

  @override
  List<Object?> get props => [accountName, error];
}

class AddLastFmAccount extends LastFmEvent {
  final String accountName;

  const AddLastFmAccount(this.accountName);

  @override
  List<Object?> get props => [accountName];
}

class RemoveLastFmAccount extends LastFmEvent {
  const RemoveLastFmAccount();

  @override
  List<Object?> get props => [];
}
