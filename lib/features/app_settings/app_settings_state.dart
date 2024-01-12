part of 'app_settings_bloc.dart';

class AppSettingsState extends Equatable {
  final LastFmAccount? lastFmAccount;
  final LoadingStatus lastFmAccountLoadingStatus;

  const AppSettingsState({
    this.lastFmAccount,
    this.lastFmAccountLoadingStatus = LoadingStatus.initial,
  });

  @override
  List<Object?> get props => [
        lastFmAccount,
        lastFmAccountLoadingStatus,
      ];

  bool get hasAccount => lastFmAccount != null;

  AppSettingsState copyWith({
    LastFmAccount? lastFmAccount,
    bool removeAccount = false,
    LoadingStatus? lastFmAccountLoadingStatus,
  }) {
    // For the Last.fm account, the state may be overwritten by null
    return AppSettingsState(
      lastFmAccount: removeAccount ? null : lastFmAccount ?? this.lastFmAccount,
      lastFmAccountLoadingStatus: lastFmAccountLoadingStatus ?? this.lastFmAccountLoadingStatus,
    );
  }
}
