import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/blocs/types.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

class ArtistsListState extends AbstractEntityUserState {
  final LoadedData<ArtistsList> loadedDataFilteredArtists;
  final bool displayTagSubtitles;
  final ModalState filterSelectionModalState;
  final Set<Tag> filterTags;
  final OverlayVisibility filterDisplayOverlayState;

  const ArtistsListState(
      {required LoadedData<TagsList> loadedDataAllTags,
      this.loadedDataFilteredArtists = const LoadedData.initial(),
      this.displayTagSubtitles = false,
      this.filterSelectionModalState = ModalState.closed,
      this.filterTags = const {},
      this.filterDisplayOverlayState = OverlayVisibility.off})
      : super(loadedDataAllTags: loadedDataAllTags);

  List<Object> get props => [
        loadedDataAllTags,
        loadedDataFilteredArtists,
        displayTagSubtitles,
        filterSelectionModalState,
        filterTags,
        filterDisplayOverlayState
      ];

  ArtistsListState copyWith({
    LoadedData<ArtistsList>? loadedDataAllArtists, // not used, but required by interface
    LoadedData<TagsList>? loadedDataAllTags,
    LoadedData<ArtistsList>? loadedDataFilteredArtists,
    bool? displayTagSubtitles,
    ModalState? filterSelectionModalState,
    Set<Tag>? filterTags,
    OverlayVisibility? filterDisplayOverlayState,
  }) {
    return ArtistsListState(
        loadedDataAllTags: loadedDataAllTags ?? this.loadedDataAllTags,
        loadedDataFilteredArtists: loadedDataFilteredArtists ?? this.loadedDataFilteredArtists,
        displayTagSubtitles: displayTagSubtitles ?? this.displayTagSubtitles,
        filterSelectionModalState: filterSelectionModalState ?? this.filterSelectionModalState,
        filterTags: filterTags != null ? filterTags : this.filterTags, // filterTags can be overridden by an empty set
        filterDisplayOverlayState:
            filterDisplayOverlayState != null ? filterDisplayOverlayState : this.filterDisplayOverlayState);
  }
}
