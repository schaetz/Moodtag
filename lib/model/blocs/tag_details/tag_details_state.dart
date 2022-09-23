import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class TagDetailsState extends Equatable {
  final int tagId;
  final LoadingStatus tagLoadingStatus;
  final Tag tag;
  final LoadingStatus artistsListLoadingStatus;
  final List<Artist> artistsWithTag;
  final bool tagEditMode;

  const TagDetailsState(
      {this.tagId,
      this.tagLoadingStatus = LoadingStatus.initial,
      this.tag,
      this.artistsListLoadingStatus = LoadingStatus.initial,
      this.artistsWithTag,
      this.tagEditMode});

  @override
  List<Object> get props => [tagId, tagLoadingStatus, tag, artistsListLoadingStatus, artistsWithTag, tagEditMode];

  TagDetailsState copyWith(
      {int tagId,
      LoadingStatus tagLoadingStatus,
      Tag tag,
      LoadingStatus artistsListLoadingStatus,
      List<Artist> artistsWithTag,
      bool tagEditMode}) {
    return TagDetailsState(
        tagId: tagId ?? this.tagId,
        tagLoadingStatus: tagLoadingStatus ?? this.tagLoadingStatus,
        tag: tag ?? this.tag,
        artistsListLoadingStatus: artistsListLoadingStatus ?? this.artistsListLoadingStatus,
        artistsWithTag: artistsWithTag ?? this.artistsWithTag,
        tagEditMode: tagEditMode);
  }
}
