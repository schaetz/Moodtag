import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class LastFmAccountManagementState extends Equatable {
  final LastFmAccount? lastFmAccount;
  final LoadingStatus accountLoadingStatus;

  const LastFmAccountManagementState({
    this.lastFmAccount,
    this.accountLoadingStatus = LoadingStatus.initial,
  });

  @override
  List<Object?> get props => [
        lastFmAccount,
        accountLoadingStatus,
      ];

  LastFmAccountManagementState copyWith({
    LastFmAccount? lastFmAccount,
    bool removeAccount = false,
    LoadingStatus? accountNameLoadingStatus,
  }) {
    // For the account, the state may be overwritten by null
    return LastFmAccountManagementState(
      lastFmAccount: removeAccount ? null : lastFmAccount ?? this.lastFmAccount,
      accountLoadingStatus: accountNameLoadingStatus ?? this.accountLoadingStatus,
    );
  }
}
