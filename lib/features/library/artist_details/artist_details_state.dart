import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/shared/bloc/library_user/library_subscriber_state_mixin.dart';
import 'package:moodtag/shared/bloc/library_user/library_subscription_sub_state.dart';

class ArtistDetailsState extends Equatable with LibrarySubscriberStateMixin {
  final int artistId;
  final LibrarySubscriptionSubState librarySubscription;
  final LoadedData<ArtistData> loadedArtistData;
  final bool tagEditMode;

  @override
  LibrarySubscriptionSubState get librarySubscriptionSubState => this.librarySubscription;

  ArtistDetailsState(
      {required this.artistId,
      this.librarySubscription = const LibrarySubscriptionSubState(),
      this.loadedArtistData = const LoadedData.initial(),
      this.tagEditMode = false});

  bool get isArtistLoaded => loadedArtistData.loadingStatus == LoadingStatus.success;

  @override
  List<Object> get props => [artistId, librarySubscription, loadedArtistData, tagEditMode];

  ArtistDetailsState copyWith(
      {int? artistId,
      LibrarySubscriptionSubState? librarySubscription,
      LoadedData<ArtistData>? loadedArtistData,
      bool? tagEditMode}) {
    return ArtistDetailsState(
        artistId: artistId ?? this.artistId,
        librarySubscription: librarySubscription ?? this.librarySubscription,
        loadedArtistData: loadedArtistData ?? this.loadedArtistData,
        tagEditMode: tagEditMode ?? this.tagEditMode);
  }
}
