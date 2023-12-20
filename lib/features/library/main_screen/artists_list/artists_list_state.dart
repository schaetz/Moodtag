import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscriber_state_mixin.dart';
import 'package:moodtag/shared/bloc/extensions/library_user/library_subscription_sub_state.dart';
import 'package:moodtag/shared/models/modal_and_overlay_types.dart';

class ArtistsListState extends Equatable with LibrarySubscriberStateMixin {
  final LibrarySubscriptionSubState librarySubscription;
  final LoadedData<ArtistsList> loadedDataFilteredArtists;
  final bool displaySearchBar;
  final String searchItem;
  final bool displayTagSubtitles;
  final ModalState filterSelectionModalState;
  final Set<Tag> filterTags;
  final bool displayFilterDisplayOverlay;

  @override
  LibrarySubscriptionSubState get librarySubscriptionSubState => this.librarySubscription;

  const ArtistsListState(
      {this.librarySubscription = const LibrarySubscriptionSubState(),
      this.loadedDataFilteredArtists = const LoadedData.initial(),
      this.displaySearchBar = false,
      this.searchItem = '',
      this.displayTagSubtitles = false,
      this.filterSelectionModalState = ModalState.closed,
      this.filterTags = const {},
      this.displayFilterDisplayOverlay = false});

  List<Object> get props => [
        librarySubscription,
        loadedDataFilteredArtists,
        displaySearchBar,
        searchItem,
        displayTagSubtitles,
        filterSelectionModalState,
        filterTags,
        displayFilterDisplayOverlay
      ];

  ArtistsListState copyWith({
    LibrarySubscriptionSubState? librarySubscription,
    LoadedData<ArtistsList>? loadedDataFilteredArtists,
    bool? displaySearchBar,
    String? searchItem,
    bool? displayTagSubtitles,
    ModalState? filterSelectionModalState,
    Set<Tag>? filterTags,
    bool? displayFilterDisplayOverlay,
  }) {
    return ArtistsListState(
        librarySubscription: librarySubscription ?? this.librarySubscription,
        loadedDataFilteredArtists: loadedDataFilteredArtists ?? this.loadedDataFilteredArtists,
        displaySearchBar: displaySearchBar ?? this.displaySearchBar,
        searchItem: searchItem ?? this.searchItem,
        displayTagSubtitles: displayTagSubtitles ?? this.displayTagSubtitles,
        filterSelectionModalState: filterSelectionModalState ?? this.filterSelectionModalState,
        filterTags: filterTags != null ? filterTags : this.filterTags, // filterTags can be overridden by an empty set
        displayFilterDisplayOverlay:
            displayFilterDisplayOverlay != null ? displayFilterDisplayOverlay : this.displayFilterDisplayOverlay);
  }
}
