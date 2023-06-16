import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class LastFmImportState extends Equatable {
  final LastFmAccount? lastFmAccount;
  final LoadingStatus accountLoadingStatus;

  const LastFmImportState({this.lastFmAccount, this.accountLoadingStatus = LoadingStatus.initial});

  @override
  List<Object?> get props => [lastFmAccount, accountLoadingStatus];

  LastFmImportState copyWith(
      {LastFmAccount? lastFmAccount, LoadingStatus? accountNameLoadingStatus, bool removeAccount = false}) {
    // For the account, the state may be overwritten by null
    return LastFmImportState(
        lastFmAccount: removeAccount ? null : lastFmAccount ?? this.lastFmAccount,
        accountLoadingStatus: accountNameLoadingStatus ?? this.accountLoadingStatus);
  }
}
