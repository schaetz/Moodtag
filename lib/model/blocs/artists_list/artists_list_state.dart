import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class ArtistsListState extends Equatable {
  final LoadingStatus loadingStatus;
  final List<ArtistData> artistsWithTags;
  final bool displayTagSubtitles;
  final Set<Tag> filterTags;

  const ArtistsListState(
      {this.loadingStatus = LoadingStatus.initial,
      this.artistsWithTags = const [],
      this.displayTagSubtitles = false,
      this.filterTags = const {}});

  @override
  List<Object> get props => [loadingStatus, artistsWithTags, displayTagSubtitles, filterTags];

  ArtistsListState copyWith({
    LoadingStatus? loadingStatus,
    List<ArtistData>? artistsWithTags,
    bool? displayTagSubtitles,
    Set<Tag>? filterTags,
  }) {
    return ArtistsListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      artistsWithTags: artistsWithTags ?? this.artistsWithTags,
      displayTagSubtitles: displayTagSubtitles ?? this.displayTagSubtitles,
      filterTags: filterTags != null ? filterTags : this.filterTags, // filterTags can be overridden by an empty set
    );
  }
}
