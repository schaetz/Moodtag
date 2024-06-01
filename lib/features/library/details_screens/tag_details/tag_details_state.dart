import 'package:equatable/equatable.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscriber_state_mixin.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscription_sub_state.dart';

class TagDetailsState extends Equatable with LibrarySubscriberStateMixin {
  final int tagId;
  final LibrarySubscriptionSubState librarySubscription;
  final LoadedData<Tag> loadedTagData;
  late final LoadedData<List<Artist>> loadedDataFilteredArtists;
  late final LoadedData<List<Artist>> loadedDataFilteredArtistsWithTag;
  final bool checklistMode;
  final bool displaySearchBar;
  final String searchItem;

  @override
  LibrarySubscriptionSubState get librarySubscriptionSubState => this.librarySubscription;

  TagDetailsState({
    required this.tagId,
    this.librarySubscription = const LibrarySubscriptionSubState(),
    this.loadedTagData = const LoadedData.initial(),
    this.loadedDataFilteredArtists = const LoadedData.initial(),
    this.loadedDataFilteredArtistsWithTag = const LoadedData.initial(),
    this.checklistMode = false,
    this.displaySearchBar = false,
    this.searchItem = '',
  });

  @override
  List<Object> get props => [
        tagId,
        librarySubscription,
        loadedTagData,
        loadedDataFilteredArtists,
        loadedDataFilteredArtistsWithTag,
        checklistMode,
        displaySearchBar,
        searchItem
      ];

  TagDetailsState copyWith({
    int? tagId,
    LibrarySubscriptionSubState? librarySubscription,
    LoadedData<Tag>? loadedTagData,
    LoadedData<List<Artist>>? loadedDataFilteredArtists,
    LoadedData<List<Artist>>? loadedDataFilteredArtistsWithTag,
    bool? checklistMode,
    bool? displaySearchBar,
    String? searchItem,
  }) {
    return TagDetailsState(
      tagId: tagId ?? this.tagId,
      librarySubscription: librarySubscription ?? this.librarySubscription,
      loadedTagData: loadedTagData ?? this.loadedTagData,
      loadedDataFilteredArtists: loadedDataFilteredArtists ?? this.loadedDataFilteredArtists,
      loadedDataFilteredArtistsWithTag: loadedDataFilteredArtistsWithTag ?? this.loadedDataFilteredArtistsWithTag,
      checklistMode: checklistMode ?? this.checklistMode,
      displaySearchBar: displaySearchBar ?? this.displaySearchBar,
      searchItem: searchItem != null ? searchItem : this.searchItem,
    );
  }
}
