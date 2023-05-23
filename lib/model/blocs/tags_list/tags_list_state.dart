import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

class TagsListState extends AbstractEntityUserState {
  TagsListState({required LoadedData<TagsList> loadedDataAllTags}) : super(loadedDataAllTags: loadedDataAllTags);

  @override
  List<Object> get props => [loadedDataAllTags];

  TagsListState copyWith({
    LoadedData<ArtistsList>? loadedDataAllArtists, // not used, but required by interface
    LoadedData<TagsList>? loadedDataAllTags,
  }) {
    return TagsListState(
      loadedDataAllTags: loadedDataAllTags ?? this.loadedDataAllTags!,
    );
  }
}
