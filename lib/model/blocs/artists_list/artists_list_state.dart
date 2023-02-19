import 'package:equatable/equatable.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class ArtistsListState extends Equatable {
  final LoadingStatus loadingStatus;
  final List<Artist> artists;
  final bool showCreateArtistDialog;
  final UserReadableException? exception;

  const ArtistsListState(
      {this.loadingStatus = LoadingStatus.initial,
      List<Artist>? artists,
      this.showCreateArtistDialog = false,
      UserReadableException? exception})
      : artists = artists ?? const [],
        exception = exception;

  @override
  List<Object> get props => [loadingStatus, artists, showCreateArtistDialog];

  ArtistsListState copyWith({
    LoadingStatus? loadingStatus,
    List<Artist>? artists,
    bool? showCreateArtistDialog,
    UserReadableException? newException,
  }) {
    return ArtistsListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      artists: artists ?? this.artists,
      showCreateArtistDialog: showCreateArtistDialog ?? this.showCreateArtistDialog,
      exception: newException ?? this.exception,
    );
  }
}
