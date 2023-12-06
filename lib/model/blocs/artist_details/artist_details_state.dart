import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class ArtistDetailsState extends AbstractEntityUserState {
  final int artistId;
  final LoadedData<ArtistData> loadedArtistData;
  final bool tagEditMode;

  ArtistDetailsState(
      {required LoadedData<TagsList> loadedDataAllTags,
      required this.artistId,
      this.loadedArtistData = const LoadedData.initial(),
      required this.tagEditMode})
      : super(loadedDataAllTags: loadedDataAllTags);

  bool get isArtistLoaded => loadedArtistData.loadingStatus == LoadingStatus.success;

  @override
  List<Object> get props => [loadedDataAllTags, artistId, loadedArtistData, tagEditMode];

  ArtistDetailsState copyWith(
      {LoadedData<ArtistsList>? loadedDataAllArtists, // not used, but required by interface
      LoadedData<TagsList>? loadedDataAllTags,
      int? artistId,
      LoadedData<ArtistData>? loadedArtistData,
      bool? tagEditMode}) {
    return ArtistDetailsState(
        loadedDataAllTags: loadedDataAllTags ?? this.loadedDataAllTags,
        artistId: artistId ?? this.artistId,
        loadedArtistData: loadedArtistData ?? this.loadedArtistData,
        tagEditMode: tagEditMode ?? this.tagEditMode);
  }
}
