import 'package:equatable/equatable.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscriber_state_mixin.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscription_sub_state.dart';

class ArtistDetailsState extends Equatable with LibrarySubscriberStateMixin {
  final int artistId;
  final LibrarySubscriptionSubState librarySubscription;
  final LoadedData<Artist> loadedArtist;
  final bool tagEditMode;

  @override
  LibrarySubscriptionSubState get librarySubscriptionSubState => this.librarySubscription;

  ArtistDetailsState(
      {required this.artistId,
      this.librarySubscription = const LibrarySubscriptionSubState(),
      this.loadedArtist = const LoadedData.initial(),
      this.tagEditMode = false});

  bool get isArtistLoaded => loadedArtist.loadingStatus == LoadingStatus.success;

  @override
  List<Object> get props => [artistId, librarySubscription, loadedArtist, tagEditMode];

  ArtistDetailsState copyWith(
      {int? artistId,
      LibrarySubscriptionSubState? librarySubscription,
      LoadedData<Artist>? loadedArtistData,
      bool? tagEditMode}) {
    return ArtistDetailsState(
        artistId: artistId ?? this.artistId,
        librarySubscription: librarySubscription ?? this.librarySubscription,
        loadedArtist: loadedArtistData ?? this.loadedArtist,
        tagEditMode: tagEditMode ?? this.tagEditMode);
  }
}
