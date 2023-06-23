import 'package:moodtag/model/database/moodtag_db.dart';

import 'library_events.dart';

abstract class LastFmEvent extends LibraryEvent {
  const LastFmEvent();
}

class LastFmAccountUpdated extends LastFmEvent {
  final LastFmAccount? lastFmAccount;
  final Object? error;

  const LastFmAccountUpdated({this.lastFmAccount, this.error});

  @override
  List<Object?> get props => [lastFmAccount, error];
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

class UpdateLastFmAccountInfo extends LastFmEvent {
  const UpdateLastFmAccountInfo();

  @override
  List<Object?> get props => [];
}
