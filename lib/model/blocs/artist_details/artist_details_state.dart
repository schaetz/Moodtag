import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class ArtistDetailsState extends Equatable {
  final int artistId;
  final LoadingStatus artistLoadingStatus;
  final Artist? artist;
  final LoadingStatus tagsListLoadingStatus;
  final List<Tag>? tagsForArtist;
  final bool tagEditMode;

  const ArtistDetailsState(
      {required this.artistId,
      this.artistLoadingStatus = LoadingStatus.initial,
      this.artist,
      this.tagsListLoadingStatus = LoadingStatus.initial,
      this.tagsForArtist,
      required this.tagEditMode});

  @override
  List<Object?> get props => [artistId, artistLoadingStatus, artist, tagsListLoadingStatus, tagsForArtist, tagEditMode];

  ArtistDetailsState copyWith(
      {int? artistId,
      LoadingStatus? artistLoadingStatus,
      Artist? artist,
      LoadingStatus? tagsListLoadingStatus,
      List<Tag>? tagsForArtist,
      bool? tagEditMode}) {
    return ArtistDetailsState(
        artistId: artistId ?? this.artistId,
        artistLoadingStatus: artistLoadingStatus ?? this.artistLoadingStatus,
        artist: artist ?? this.artist,
        tagsListLoadingStatus: tagsListLoadingStatus ?? this.tagsListLoadingStatus,
        tagsForArtist: tagsForArtist ?? this.tagsForArtist,
        tagEditMode: tagEditMode ?? this.tagEditMode);
  }
}
