import 'package:moodtag/model/blocs/entity_loader/entity_loader_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_object.dart';

class TagsListState extends EntityLoaderUserState<TagsListState> {
  TagsListState({required LoadedObject<List<TagData>> allTags}) : super(allTags: allTags, allArtistsWithTags: null);

  @override
  List<Object?> get props => [allTags];

  TagsListState copyWith({
    LoadedObject<List<TagData>>? allTags,
  }) {
    return TagsListState(
      allTags: allTags ?? this.allTags!,
    );
  }
}
