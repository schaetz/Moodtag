import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_tag.dart';

import 'import_events.dart';

abstract class LastFmImportEvent extends ImportEvent {
  const LastFmImportEvent();
}

class LastFmAccountUpdated extends LastFmImportEvent {
  final LastFmAccount? lastFmAccount;
  final Object? error;

  const LastFmAccountUpdated({this.lastFmAccount, this.error});

  @override
  List<Object?> get props => [lastFmAccount, error];
}

class AddLastFmAccount extends LastFmImportEvent {
  final String accountName;

  const AddLastFmAccount(this.accountName);

  @override
  List<Object?> get props => [accountName];
}

class RemoveLastFmAccount extends LastFmImportEvent {
  const RemoveLastFmAccount();

  @override
  List<Object?> get props => [];
}

class UpdateLastFmAccountInfo extends LastFmImportEvent {
  const UpdateLastFmAccountInfo();

  @override
  List<Object?> get props => [];
}

class CompleteLastFmImport extends ImportEvent {
  final List<ImportedArtist> selectedArtists;
  final List<ImportedTag> selectedTags;

  CompleteLastFmImport(this.selectedArtists, this.selectedTags);

  @override
  List<Object?> get props => [selectedArtists, selectedTags];
}
