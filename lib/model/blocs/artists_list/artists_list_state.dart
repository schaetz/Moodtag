import 'package:equatable/equatable.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class ArtistsListState extends Equatable {
  final LoadingStatus loadingStatus;
  final List<Artist> artists;

  const ArtistsListState(
      {this.loadingStatus = LoadingStatus.initial, List<Artist>? artists, UserReadableException? exception})
      : artists = artists ?? const [];

  @override
  List<Object> get props => [loadingStatus, artists];

  ArtistsListState copyWith({
    LoadingStatus? loadingStatus,
    List<Artist>? artists,
  }) {
    return ArtistsListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      artists: artists ?? this.artists,
    );
  }
}
