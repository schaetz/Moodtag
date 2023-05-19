import 'package:moodtag/model/blocs/entity_loader/entity_loader_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_object.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class TagsListState extends EntityLoaderUserState {
  // List<Tag> get tags => _tagsWithArtistFreq.map((tagWithFreq) => tagWithFreq.tag).toList();
  // List<TagData> get artistFrequencies => _tagsWithArtistFreq;

  TagsListState({this.loadingStatus = LoadingStatus.initial, LoadedObject<List<TagData>>? tagsWithArtistFreq})
      : _tags = tagsWithArtistFreq ?? LoadedObject.initial();

  @override
  List<Object> get props => [loadingStatus, _tags];

  TagsListState copyWith({
    LoadingStatus? loadingStatus,
    LoadedObject<List<TagData>>? tagsWithArtistFreq,
  }) {
    return TagsListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      tagsWithArtistFreq: tagsWithArtistFreq ?? this._tags,
    );
  }
}
