import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class TagsListState extends Equatable {
  final LoadingStatus loadingStatus;
  final List<TagWithArtistFreq> _tagsWithArtistFreq;

  List<Tag> get tags => _tagsWithArtistFreq.map((tagWithFreq) => tagWithFreq.tag).toList();
  List<TagWithArtistFreq> get artistFrequencies => _tagsWithArtistFreq;

  const TagsListState({this.loadingStatus = LoadingStatus.initial, List<TagWithArtistFreq>? tagsWithArtistFreq})
      : _tagsWithArtistFreq = tagsWithArtistFreq ?? const [];

  @override
  List<Object> get props => [loadingStatus, _tagsWithArtistFreq];

  TagsListState copyWith({
    LoadingStatus? loadingStatus,
    List<TagWithArtistFreq>? tagsWithArtistFreq,
  }) {
    return TagsListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      tagsWithArtistFreq: tagsWithArtistFreq ?? this._tagsWithArtistFreq,
    );
  }
}
