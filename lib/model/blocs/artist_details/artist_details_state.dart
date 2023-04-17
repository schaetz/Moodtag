import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class ArtistDetailsState extends Equatable {
  final int artistId;
  final LoadingStatus artistLoadingStatus;
  final Artist? artist;
  final LoadingStatus tagsForArtistLoadingStatus;
  final List<Tag>? tagsForArtist;
  final LoadingStatus allTagsLoadingStatus;
  final List<Tag>? allTags;
  final bool tagEditMode;

  const ArtistDetailsState(
      {required this.artistId,
      this.artistLoadingStatus = LoadingStatus.initial,
      this.artist,
      this.tagsForArtistLoadingStatus = LoadingStatus.initial,
      this.tagsForArtist,
      this.allTagsLoadingStatus = LoadingStatus.initial,
      this.allTags,
      required this.tagEditMode});

  @override
  List<Object?> get props => [
        artistId,
        artistLoadingStatus,
        artist,
        tagsForArtistLoadingStatus,
        tagsForArtist,
        allTagsLoadingStatus,
        allTags,
        tagEditMode
      ];

  ArtistDetailsState copyWith(
      {int? artistId,
      LoadingStatus? artistLoadingStatus,
      Artist? artist,
      LoadingStatus? tagsForArtistLoadingStatus,
      List<Tag>? tagsForArtist,
      LoadingStatus? allTagsLoadingStatus,
      List<Tag>? allTags,
      bool? tagEditMode}) {
    return ArtistDetailsState(
        artistId: artistId ?? this.artistId,
        artistLoadingStatus: artistLoadingStatus ?? this.artistLoadingStatus,
        artist: artist ?? this.artist,
        tagsForArtistLoadingStatus: tagsForArtistLoadingStatus ?? this.tagsForArtistLoadingStatus,
        tagsForArtist: tagsForArtist ?? this.tagsForArtist,
        allTagsLoadingStatus: allTagsLoadingStatus ?? this.allTagsLoadingStatus,
        allTags: allTags ?? this.allTags,
        tagEditMode: tagEditMode ?? this.tagEditMode);
  }
}
