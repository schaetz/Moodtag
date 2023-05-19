import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/loaded_object.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class ArtistDetailsState extends AbstractEntityUserState {
  final int artistId;
  final LoadingStatus artistLoadingStatus;
  final Artist? artist;
  final LoadingStatus tagsForArtistLoadingStatus;
  final List<Tag>? tagsForArtist;
  final bool tagEditMode;

  ArtistDetailsState(
      {required LoadedData<TagsList> loadedDataAllTags,
      required this.artistId,
      this.artistLoadingStatus = LoadingStatus.initial,
      this.artist,
      this.tagsForArtistLoadingStatus = LoadingStatus.initial,
      this.tagsForArtist,
      required this.tagEditMode})
      : super(loadedDataAllTags: loadedDataAllTags);

  @override
  List<Object?> get props => [
        loadedDataAllTags,
        artistId,
        artistLoadingStatus,
        artist,
        tagsForArtistLoadingStatus,
        tagsForArtist,
        tagEditMode
      ];

  ArtistDetailsState copyWith(
      {LoadedData<ArtistsList>? loadedDataAllArtists, // not used, but required by interface
      LoadedData<TagsList>? loadedDataAllTags,
      int? artistId,
      LoadingStatus? artistLoadingStatus,
      Artist? artist,
      LoadingStatus? tagsForArtistLoadingStatus,
      List<Tag>? tagsForArtist,
      LoadingStatus? allTagsLoadingStatus,
      List<Tag>? allTags,
      bool? tagEditMode}) {
    return ArtistDetailsState(
        loadedDataAllTags: loadedDataAllTags ?? this.loadedDataAllTags!,
        artistId: artistId ?? this.artistId,
        artistLoadingStatus: artistLoadingStatus ?? this.artistLoadingStatus,
        artist: artist ?? this.artist,
        tagsForArtistLoadingStatus: tagsForArtistLoadingStatus ?? this.tagsForArtistLoadingStatus,
        tagsForArtist: tagsForArtist ?? this.tagsForArtist,
        tagEditMode: tagEditMode ?? this.tagEditMode);
  }
}
