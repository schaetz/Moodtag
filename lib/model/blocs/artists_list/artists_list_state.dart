import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

class ArtistsListState extends AbstractEntityUserState {
  final LoadedData<ArtistsList> loadedDataFilteredArtists;
  final bool displayTagSubtitles;
  final bool showFilterOverlay;
  final Set<Tag> filterTags;

  const ArtistsListState(
      {required LoadedData<TagsList> loadedDataAllTags,
      this.loadedDataFilteredArtists = const LoadedData.initial(),
      this.displayTagSubtitles = false,
      this.showFilterOverlay = false,
      this.filterTags = const {}})
      : super(loadedDataAllTags: loadedDataAllTags);

  List<Object> get props =>
      [loadedDataAllTags, loadedDataFilteredArtists, displayTagSubtitles, showFilterOverlay, filterTags];

  ArtistsListState copyWith({
    LoadedData<ArtistsList>? loadedDataAllArtists, // not used, but required by interface
    LoadedData<TagsList>? loadedDataAllTags,
    LoadedData<ArtistsList>? loadedDataFilteredArtists,
    bool? displayTagSubtitles,
    bool? showFilterOverlay,
    Set<Tag>? filterTags,
  }) {
    return ArtistsListState(
      loadedDataAllTags: loadedDataAllTags ?? this.loadedDataAllTags,
      loadedDataFilteredArtists: loadedDataFilteredArtists ?? this.loadedDataFilteredArtists,
      displayTagSubtitles: displayTagSubtitles ?? this.displayTagSubtitles,
      showFilterOverlay: showFilterOverlay ?? this.showFilterOverlay,
      filterTags: filterTags != null ? filterTags : this.filterTags, // filterTags can be overridden by an empty set
    );
  }
}
