import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

enum TagsStatus { initial, success, error, loading, selected }

extension TagsStatusX on TagsStatus {
  bool get isInitial => this == TagsStatus.initial;
  bool get isSuccess => this == TagsStatus.success;
  bool get isError => this == TagsStatus.error;
  bool get isLoading => this == TagsStatus.loading;
  bool get isSelected => this == TagsStatus.selected;
}

class TagsState extends Equatable {
  final TagsStatus status;
  final List<Tag> tags;
  final Tag selectedTag;
  final List<Artist> artistsWithSelectedTag;

  const TagsState(
      {this.status = TagsStatus.initial, List<Tag> tags, Tag selectedTag, List<Artist> artistsWithSelectedTag})
      : tags = tags ?? const [],
        selectedTag = selectedTag,
        artistsWithSelectedTag = artistsWithSelectedTag;

  @override
  List<Object> get props => [status, tags, selectedTag];

  TagsState copyWith({TagsStatus status, List<Tag> tags, Tag selectedTag, List<Artist> artistsWithSelectedTag}) {
    return TagsState(
        status: status ?? this.status,
        tags: tags ?? this.tags,
        selectedTag: selectedTag ?? this.selectedTag,
        artistsWithSelectedTag: artistsWithSelectedTag ?? this.artistsWithSelectedTag);
  }
}
