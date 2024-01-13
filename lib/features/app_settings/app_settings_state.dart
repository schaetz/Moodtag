part of 'app_settings_bloc.dart';

class AppSettingsState extends Equatable with LibrarySubscriberStateMixin {
  final LibrarySubscriptionSubState librarySubscription;
  final LastFmAccount? lastFmAccount;
  final LoadingStatus lastFmAccountLoadingStatus;

  const AppSettingsState({
    this.librarySubscription = const LibrarySubscriptionSubState(),
    this.lastFmAccount,
    this.lastFmAccountLoadingStatus = LoadingStatus.initial,
  });

  @override
  LibrarySubscriptionSubState get librarySubscriptionSubState => this.librarySubscription;

  @override
  List<Object?> get props => [
        librarySubscription,
        lastFmAccount,
        lastFmAccountLoadingStatus,
      ];

  bool get hasAccount => lastFmAccount != null;

  AppSettingsState copyWith({
    LibrarySubscriptionSubState? librarySubscription,
    LastFmAccount? lastFmAccount,
    bool removeAccount = false,
    LoadingStatus? lastFmAccountLoadingStatus,
  }) {
    // For the Last.fm account, the state may be overwritten by null
    return AppSettingsState(
      librarySubscription: librarySubscription ?? this.librarySubscription,
      lastFmAccount: removeAccount ? null : lastFmAccount ?? this.lastFmAccount,
      lastFmAccountLoadingStatus: lastFmAccountLoadingStatus ?? this.lastFmAccountLoadingStatus,
    );
  }
}
