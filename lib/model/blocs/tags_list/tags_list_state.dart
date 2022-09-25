import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class TagsListState extends Equatable {
  final LoadingStatus loadingStatus;
  final List<Tag> tags;

  const TagsListState({
    this.loadingStatus = LoadingStatus.initial,
    List<Tag>? tags,
  }) : tags = tags ?? const [];

  @override
  List<Object> get props => [loadingStatus, tags];

  TagsListState copyWith({LoadingStatus? loadingStatus, List<Tag>? tags}) {
    return TagsListState(loadingStatus: loadingStatus ?? this.loadingStatus, tags: tags ?? this.tags);
  }
}
