import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/join_data_classes.dart';

class ArtistsListState extends Equatable {
  final LoadingStatus loadingStatus;
  final List<ArtistWithTags> artistsWithTags;
  final bool displayTagSubtitles;

  const ArtistsListState(
      {this.loadingStatus = LoadingStatus.initial, this.artistsWithTags = const [], this.displayTagSubtitles = false});

  @override
  List<Object> get props => [loadingStatus, artistsWithTags, displayTagSubtitles];

  ArtistsListState copyWith({
    LoadingStatus? loadingStatus,
    List<ArtistWithTags>? artistsWithTags,
    bool? displayTagSubtitles,
  }) {
    return ArtistsListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      artistsWithTags: artistsWithTags ?? this.artistsWithTags,
      displayTagSubtitles: displayTagSubtitles ?? this.displayTagSubtitles,
    );
  }
}
