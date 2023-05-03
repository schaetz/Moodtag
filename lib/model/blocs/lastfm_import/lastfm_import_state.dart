import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';

class LastFmImportState extends Equatable {
  final String? accountName;
  final LoadingStatus accountNameLoadingStatus;

  const LastFmImportState({this.accountName, this.accountNameLoadingStatus = LoadingStatus.initial});

  @override
  List<Object?> get props => [accountName, accountNameLoadingStatus];

  LastFmImportState copyWith(
      {String? accountName, LoadingStatus? accountNameLoadingStatus, bool updateAccountName = false}) {
    return LastFmImportState(
        accountName:
            updateAccountName ? accountName : this.accountName, // For accountName, the state may be overwritten by null
        accountNameLoadingStatus: accountNameLoadingStatus ?? this.accountNameLoadingStatus);
  }
}
