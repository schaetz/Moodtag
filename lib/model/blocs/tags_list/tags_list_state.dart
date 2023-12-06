import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

class TagsListState extends AbstractEntityUserState {
  final LoadedData<TagsList> loadedDataFilteredTags;
  final bool displaySearchBar;
  final String searchItem;

  const TagsListState({
    required LoadedData<TagsList> loadedDataAllTags,
    this.loadedDataFilteredTags = const LoadedData.initial(),
    this.displaySearchBar = false,
    this.searchItem = '',
  }) : super(loadedDataAllTags: loadedDataAllTags);

  @override
  List<Object> get props => [loadedDataAllTags, loadedDataFilteredTags, displaySearchBar, searchItem];

  TagsListState copyWith({
    LoadedData<ArtistsList>? loadedDataAllArtists, // not used, but required by interface
    LoadedData<TagsList>? loadedDataAllTags,
    LoadedData<TagsList>? loadedDataFilteredTags,
    bool? displaySearchBar,
    String? searchItem,
  }) {
    return TagsListState(
      loadedDataAllTags: loadedDataAllTags ?? this.loadedDataAllTags,
      loadedDataFilteredTags: loadedDataFilteredTags ?? this.loadedDataFilteredTags,
      displaySearchBar: displaySearchBar ?? this.displaySearchBar,
      searchItem: searchItem ?? this.searchItem,
    );
  }
}
