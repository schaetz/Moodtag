import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/ILibraryUserState.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

class TagsListState extends Equatable implements ILibraryUserState {
  final LoadedData<TagsList> loadedDataAllTags;
  final LoadedData<TagsList> loadedDataFilteredTags;
  final bool displaySearchBar;
  final String searchItem;

  @override
  LoadedData<ArtistsList>? get allArtistsData => null;

  @override
  LoadedData<TagsList>? get allTagsData => loadedDataAllTags;

  const TagsListState({
    this.loadedDataAllTags = const LoadedData.initial(),
    this.loadedDataFilteredTags = const LoadedData.initial(),
    this.displaySearchBar = false,
    this.searchItem = '',
  });

  @override
  List<Object> get props => [loadedDataAllTags, loadedDataFilteredTags, displaySearchBar, searchItem];

  TagsListState copyWith({
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
