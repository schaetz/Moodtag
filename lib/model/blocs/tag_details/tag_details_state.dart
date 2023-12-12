import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/library_user/library_subscriber_state_mixin.dart';
import 'package:moodtag/model/blocs/library_user/library_subscription_sub_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

class TagDetailsState extends Equatable with LibrarySubscriberStateMixin {
  final int tagId;
  final LibrarySubscriptionSubState librarySubscription;
  final LoadedData<TagData> loadedTagData;
  final bool checklistMode;

  // deduced properties
  // TODO Where do we get this from?
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
  List<Object> get props => [tagId, librarySubscription, loadedTagData, checklistMode];

  TagDetailsState copyWith(
      {int? tagId,
      LibrarySubscriptionSubState? librarySubscription,
      LoadedData<TagData>? loadedTagData,
      bool? checklistMode}) {
    return TagDetailsState(
        tagId: tagId ?? this.tagId,
        librarySubscription: librarySubscription ?? this.librarySubscription,
        loadedTagData: loadedTagData ?? this.loadedTagData,
        checklistMode: checklistMode ?? this.checklistMode);
  }
}
