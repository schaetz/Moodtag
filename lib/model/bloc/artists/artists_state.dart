import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

enum ArtistsStatus { initial, success, error, loading, selected }

extension ArtistsStatusX on ArtistsStatus {
  bool get isInitial => this == ArtistsStatus.initial;
  bool get isSuccess => this == ArtistsStatus.success;
  bool get isError => this == ArtistsStatus.error;
  bool get isLoading => this == ArtistsStatus.loading;
  bool get isSelected => this == ArtistsStatus.selected;
}

class ArtistsState extends Equatable {
  final ArtistsStatus status;
  final List<Artist> artists;
  final Artist selectedArtist;
  final List<Tag> tagsWithSelectedArtist; // TODO Initialize this when an artist is selected

  const ArtistsState({
    this.status = ArtistsStatus.initial,
    List<Artist> artists,
    Artist selectedArtist,
    List<Tag> tagsWithSelectedArtist,
  })  : artists = artists ?? const [],
        selectedArtist = selectedArtist,
        tagsWithSelectedArtist = tagsWithSelectedArtist;

  @override
  List<Object> get props => [status, artists, selectedArtist];

  ArtistsState copyWith({
    ArtistsStatus status,
    List<Artist> artists,
    Artist selectedArtist,
    List<Tag> tagsWithSelectedArtist,
  }) {
    return ArtistsState(
      status: status ?? this.status,
      artists: artists ?? this.artists,
      selectedArtist: selectedArtist ?? this.selectedArtist,
      tagsWithSelectedArtist: tagsWithSelectedArtist ?? this.tagsWithSelectedArtist,
    );
  }
}
