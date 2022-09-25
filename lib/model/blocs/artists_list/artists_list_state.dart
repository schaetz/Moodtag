import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class ArtistsListState extends Equatable {
  final LoadingStatus loadingStatus;
  final List<Artist> artists;
  final bool showCreateArtistDialog;

  const ArtistsListState(
      {this.loadingStatus = LoadingStatus.initial, List<Artist>? artists, this.showCreateArtistDialog = false})
      : artists = artists ?? const [];

  @override
  List<Object> get props => [loadingStatus, artists, showCreateArtistDialog];

  ArtistsListState copyWith({
    LoadingStatus? loadingStatus,
    List<Artist>? artists,
    bool? showCreateArtistDialog,
  }) {
    return ArtistsListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      artists: artists ?? this.artists,
      showCreateArtistDialog: showCreateArtistDialog ?? this.showCreateArtistDialog,
    );
  }
}
