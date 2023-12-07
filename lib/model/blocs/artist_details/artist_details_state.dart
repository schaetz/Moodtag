import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class ArtistDetailsState extends Equatable {
  final int artistId;
  final LoadedData<ArtistData> loadedArtistData;
  final LoadedData<TagsList> loadedDataAllTags;
  final bool tagEditMode;

  ArtistDetailsState(
      {required this.artistId,
      this.loadedArtistData = const LoadedData.initial(),
      this.loadedDataAllTags = const LoadedData.initial(),
      this.tagEditMode = false});

  bool get isArtistLoaded => loadedArtistData.loadingStatus == LoadingStatus.success;

  @override
  List<Object> get props => [artistId, loadedArtistData, loadedDataAllTags, tagEditMode];

  ArtistDetailsState copyWith(
      {int? artistId,
      LoadedData<ArtistData>? loadedArtistData,
      LoadedData<TagsList>? loadedDataAllTags,
      bool? tagEditMode}) {
    return ArtistDetailsState(
        artistId: artistId ?? this.artistId,
        loadedArtistData: loadedArtistData ?? this.loadedArtistData,
        loadedDataAllTags: loadedDataAllTags ?? this.loadedDataAllTags,
        tagEditMode: tagEditMode ?? this.tagEditMode);
  }
}
