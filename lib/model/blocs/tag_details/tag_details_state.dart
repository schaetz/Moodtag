import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class TagDetailsState extends Equatable {
  final int tagId;
  final LoadingStatus tagLoadingStatus;
  final Tag? tag;
  final LoadingStatus artistsListLoadingStatus;
  final List<ArtistWithTagFlag>? artistsWithTagFlag;
  final bool checklistMode;

  // redundant properties
  late final List<ArtistWithTagFlag> artistsWithTagOnly;

  TagDetailsState(
      {required this.tagId,
      this.tagLoadingStatus = LoadingStatus.initial,
      this.tag,
      this.artistsListLoadingStatus = LoadingStatus.initial,
      this.artistsWithTagFlag,
      required this.checklistMode}) {
    artistsWithTagOnly = artistsWithTagFlag?.where((artistPlus) => artistPlus.hasTag).toList() ?? <ArtistWithTagFlag>[];
  }

  @override
  List<Object?> get props =>
      [tagId, tagLoadingStatus, tag, artistsListLoadingStatus, artistsWithTagFlag, checklistMode];

  TagDetailsState copyWith(
      {int? tagId,
      LoadingStatus? tagLoadingStatus,
      Tag? tag,
      LoadingStatus? artistsListLoadingStatus,
      List<ArtistWithTagFlag>? artistsWithTagFlag,
      bool? checklistMode}) {
    return TagDetailsState(
        tagId: tagId ?? this.tagId,
        tagLoadingStatus: tagLoadingStatus ?? this.tagLoadingStatus,
        tag: tag ?? this.tag,
        artistsListLoadingStatus: artistsListLoadingStatus ?? this.artistsListLoadingStatus,
        artistsWithTagFlag: artistsWithTagFlag ?? this.artistsWithTagFlag,
        checklistMode: checklistMode ?? this.checklistMode);
  }
}
