import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscriber_state_mixin.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscription_sub_state.dart';

class TagDetailsState extends Equatable with LibrarySubscriberStateMixin {
  final int tagId;
  final LibrarySubscriptionSubState librarySubscription;
  final LoadedData<TagData> loadedTagData;
  final bool checklistMode;
  late final LoadedData<List<ArtistData>> artistsWithThisTagOnly;

  @override
  LibrarySubscriptionSubState get librarySubscriptionSubState => this.librarySubscription;

  TagDetailsState(
      {required this.tagId,
      this.librarySubscription = const LibrarySubscriptionSubState(),
      this.loadedTagData = const LoadedData.initial(),
      this.checklistMode = false,
      this.artistsWithThisTagOnly = const LoadedData.initial()});

  @override
  List<Object> get props => [tagId, librarySubscription, loadedTagData, checklistMode, artistsWithThisTagOnly];

  TagDetailsState copyWith(
      {int? tagId,
      LibrarySubscriptionSubState? librarySubscription,
      LoadedData<TagData>? loadedTagData,
      bool? checklistMode,
      LoadedData<ArtistsList>? artistsWithThisTagOnly}) {
    return TagDetailsState(
        tagId: tagId ?? this.tagId,
        librarySubscription: librarySubscription ?? this.librarySubscription,
        loadedTagData: loadedTagData ?? this.loadedTagData,
        checklistMode: checklistMode ?? this.checklistMode,
        artistsWithThisTagOnly: artistsWithThisTagOnly ?? this.artistsWithThisTagOnly);
  }
}
