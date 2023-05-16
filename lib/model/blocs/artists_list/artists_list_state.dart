import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/join_data_classes.dart';

class ArtistsListState extends Equatable {
  final LoadingStatus loadingStatus;
  final List<ArtistWithTags> artistsWithTags;

  const ArtistsListState({this.loadingStatus = LoadingStatus.initial, this.artistsWithTags = const []});

  @override
  List<Object> get props => [loadingStatus, artistsWithTags];

  ArtistsListState copyWith({
    LoadingStatus? loadingStatus,
    List<ArtistWithTags>? artistsWithTags,
  }) {
    return ArtistsListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      artistsWithTags: artistsWithTags ?? this.artistsWithTags,
    );
  }
}
